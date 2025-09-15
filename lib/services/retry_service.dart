import 'dart:async';
import 'dart:io';
import '../config/api_config.dart';

class RetryService {
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxRetries = ApiConfig.maxRetries,
    Duration delay = ApiConfig.retryDelay,
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } on Exception catch (e) {
        lastException = e;
        attempts++;

        // Check if we should retry this exception
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        // Don't retry on the last attempt
        if (attempts >= maxRetries) {
          break;
        }

        // Wait before retrying
        await Future.delayed(delay * attempts); // Exponential backoff
      }
    }

    throw lastException ?? Exception('Operation failed after $maxRetries attempts');
  }

  // Default retry conditions
  static bool defaultShouldRetry(Exception e) {
    if (e is SocketException) return true;
    if (e is HttpException) return true;
    if (e is TimeoutException) return true;
    
    // Don't retry authentication errors
    if (e.toString().contains('401') || e.toString().contains('403')) {
      return false;
    }
    
    // Don't retry client errors (4xx)
    if (e.toString().contains('400') || e.toString().contains('404')) {
      return false;
    }
    
    // Retry server errors (5xx)
    if (e.toString().contains('500') || e.toString().contains('502') || e.toString().contains('503')) {
      return true;
    }
    
    return false;
  }

  // Network-specific retry
  static Future<T> retryNetworkOperation<T>(Future<T> Function() operation) async {
    return retry(
      operation,
      shouldRetry: defaultShouldRetry,
    );
  }

  // API-specific retry
  static Future<T> retryApiOperation<T>(Future<T> Function() operation) async {
    return retry(
      operation,
      maxRetries: 2, // Fewer retries for API calls
      delay: const Duration(seconds: 1),
      shouldRetry: (e) {
        // Only retry on network issues or server errors
        return e is SocketException || 
               e is TimeoutException ||
               e.toString().contains('500') ||
               e.toString().contains('502') ||
               e.toString().contains('503');
      },
    );
  }
}
