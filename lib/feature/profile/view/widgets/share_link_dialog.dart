import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:share_plus/share_plus.dart';


class ShareLinkDialog extends StatelessWidget {
  final String shareUrl;
  final String shareMessage;

  const ShareLinkDialog({
    super.key,
    this.shareUrl = 'https://yourapp.com/invite',
    this.shareMessage = 'Use this app with me! 🎉',
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Dialog(
      insetPadding: ResponsiveHelper.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.borderRadius(20),
        ),
      ),
      child: Container(
        width: ResponsiveHelper.isTablet
            ? ResponsiveHelper.maxContentWidth
            : double.infinity,
        padding: ResponsiveHelper.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share Link',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.titleFontSize(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    size: ResponsiveHelper.iconSize(24),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.spacing(16)),

            /// Share Icon
            Container(
              width: ResponsiveHelper.width(80),
              height: ResponsiveHelper.height(80),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.share_rounded,
                size: ResponsiveHelper.iconSize(40),
                color: Theme.of(context).primaryColor,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(16)),

            /// Title
            Text(
              'Share with your friends',
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(8)),

            /// Subtitle
            Text(
              'Share this link to invite your friends',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(13),
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(20)),

            /// Link Box
            Container(
              padding: ResponsiveHelper.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(12),
                ),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: ResponsiveHelper.borderWidth(1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shareUrl,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(13),
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(width: ResponsiveHelper.spacing(8)),

                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: shareUrl),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy_rounded,
                      size: ResponsiveHelper.iconSize(20),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(20)),

            /// Share Button
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(50),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _shareLink();
                },
                icon: Icon(
                  Icons.share_rounded,
                  size: ResponsiveHelper.iconSize(20),
                ),
                label: Text(
                  'Share',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(15),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareLink() {
    Share.share(
      '$shareMessage\n\n$shareUrl',
      subject: 'App Invitation',
    );
  }
}