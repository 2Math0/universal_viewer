import 'package:flutter_test/flutter_test.dart';
import 'package:universal_viewer/universal_viewer.dart';

void main() {
  group('ContentDetector', () {
    test('detects YouTube URLs', () {
      expect(
        ContentDetector.detect(url: 'https://www.youtube.com/watch?v=test'),
        ContentType.youtube,
      );
      expect(
        ContentDetector.detect(url: 'https://youtu.be/test'),
        ContentType.youtube,
      );
    });

    test('detects Vimeo URLs', () {
      expect(
        ContentDetector.detect(url: 'https://vimeo.com/123456'),
        ContentType.vimeo,
      );
    });

    test('detects file types by extension', () {
      expect(
        ContentDetector.detect(fileName: 'document.pdf'),
        ContentType.pdf,
      );
      expect(
        ContentDetector.detect(fileName: 'image.jpg'),
        ContentType.image,
      );
      expect(
        ContentDetector.detect(fileName: 'video.mp4'),
        ContentType.video,
      );
    });

    test('detects web URLs', () {
      expect(
        ContentDetector.detect(url: 'https://example.com'),
        ContentType.web,
      );
    });

    test('detects HTML content', () {
      expect(
        ContentDetector.detect(htmlContent: '<h1>Test</h1>'),
        ContentType.html,
      );
    });
  });

  group('UrlUtility', () {
    test('validates URLs correctly', () {
      expect(UrlUtility.isValidUrl('https://example.com'), true);
      expect(UrlUtility.isValidUrl('http://example.com'), true);
      expect(UrlUtility.isValidUrl('not a url'), false);
      expect(UrlUtility.isValidUrl(''), false);
    });

    test('converts YouTube URLs to embed format', () {
      expect(
        UrlUtility.toYouTubeEmbedUrl('https://www.youtube.com/watch?v=test123'),
        'https://www.youtube.com/embed/test123',
      );
      expect(
        UrlUtility.toYouTubeEmbedUrl('https://youtu.be/test123'),
        'https://www.youtube.com/embed/test123',
      );
    });

    test('converts Vimeo URLs to embed format', () {
      expect(
        UrlUtility.toVimeoEmbedUrl('https://vimeo.com/123456'),
        'https://player.vimeo.com/video/123456',
      );
    });
  });

  group('ViewerController', () {
    test('initializes with loading state', () {
      final controller = ViewerController();
      expect(controller.value.isLoading, true);
      expect(controller.value.hasError, false);
      controller.dispose();
    });

    test('updates state correctly', () {
      final controller = ViewerController();

      controller.setContent(
        objectUrl: 'https://example.com',
        contentType: ContentType.web,
      );

      expect(controller.value.isLoading, false);
      expect(controller.value.objectUrl, 'https://example.com');
      expect(controller.value.contentType, ContentType.web);

      controller.dispose();
    });

    test('handles errors correctly', () {
      final controller = ViewerController();

      controller.setError('Test error');

      expect(controller.value.hasError, true);
      expect(controller.value.error, 'Test error');
      expect(controller.value.isLoading, false);

      controller.dispose();
    });

    test('toggles visibility correctly', () {
      final controller = ViewerController();

      expect(controller.value.isHidden, false);

      controller.hide();
      expect(controller.value.isHidden, true);

      controller.show();
      expect(controller.value.isHidden, false);

      controller.toggleVisibility();
      expect(controller.value.isHidden, true);

      controller.dispose();
    });
  });

  group('FileUtility', () {
    test('gets correct MIME types', () {
      expect(
        FileUtility.getMimeType(fileName: 'test.pdf'),
        'application/pdf',
      );
      expect(
        FileUtility.getMimeType(fileName: 'test.jpg'),
        'image/jpeg',
      );
    });

    test('extracts file extensions', () {
      expect(FileUtility.getExtension('document.pdf'), 'pdf');
      expect(FileUtility.getExtension('image.png'), 'png');
      expect(FileUtility.getExtension('noextension'), null);
    });

    test('formats file sizes correctly', () {
      expect(FileUtility.formatFileSize(500), '500 B');
      expect(FileUtility.formatFileSize(1024), '1.00 KB');
      expect(FileUtility.formatFileSize(1048576), '1.00 MB');
      expect(FileUtility.formatFileSize(1073741824), '1.00 GB');
    });

    test('sanitizes file names', () {
      expect(
        FileUtility.sanitizeFileName('file<name>.pdf'),
        'file_name_.pdf',
      );
      expect(
        FileUtility.sanitizeFileName('normal_file.txt'),
        'normal_file.txt',
      );
    });
  });

  group('ContentType', () {
    test('has correct properties', () {
      expect(ContentType.pdf.name, 'PDF');
      expect(ContentType.pdf.extensions, contains('pdf'));
      expect(ContentType.pdf.isDownloadable, true);
      expect(ContentType.pdf.requiresHtmlView, true);
    });

    test('identifies online services', () {
      expect(ContentType.youtube.isOnlineService, true);
      expect(ContentType.vimeo.isOnlineService, true);
      expect(ContentType.web.isOnlineService, true);
      expect(ContentType.pdf.isOnlineService, false);
    });

    test('identifies downloadable content', () {
      expect(ContentType.pdf.isDownloadable, true);
      expect(ContentType.image.isDownloadable, true);
      expect(ContentType.youtube.isDownloadable, false);
      expect(ContentType.web.isDownloadable, false);
    });
  });
}