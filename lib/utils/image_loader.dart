import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageLoader {
	/// Convert a path from the JSON format to Flutter asset path
	/// Examples:
	///   /uploads/2025/image.jpg -> assets/images/uploads/2025/image.jpg
	///   /assets/images/logo.png -> assets/images/logo.png
	/// 
	/// Note: For Flutter Web, Image.asset expects paths with 'assets/' prefix
	/// but the web renderer adds '/assets/' automatically, so we keep the full path
	static String toAssetPath(String path) {
		final String originalPath = path;
		String assetPath;
		
		if (path.startsWith('/uploads/')) {
			assetPath = 'assets/images${path}';
		} else if (path.startsWith('/assets/images/')) {
			assetPath = path.substring(1); // Remove leading slash: 'assets/images/logo.png'
		} else if (path.startsWith('assets/')) {
			// Already in correct format
			assetPath = path;
		} else if (!path.startsWith('/')) {
			// Path might already be relative, try as-is
			assetPath = path;
		} else {
			// Unknown format, return as-is
			assetPath = path;
		}
		
		return assetPath;
	}

	/// Get an ImageProvider for the given path
	/// Tries asset first, falls back to network if needed
	static ImageProvider getImageProvider(String path) {
		final assetPath = toAssetPath(path);
		try {
			return AssetImage(assetPath);
		} catch (e) {
			// Fallback to network image if asset fails
			return NetworkImage(path);
		}
	}

	/// Load image as a widget with error handling
	/// Supports both raster images (PNG, JPEG) and SVG images
	static Widget loadImage(
		String path, {
		BoxFit fit = BoxFit.cover,
		double? width,
		double? height,
		Widget? errorWidget,
	}) {
		String assetPath = toAssetPath(path);
		
		// On Flutter Web, strip 'assets/' prefix to avoid double prefix issue
		// Flutter Web automatically prepends '/assets/' to asset paths
		if (kIsWeb && assetPath.startsWith('assets/')) {
			assetPath = assetPath.substring(7); // Remove 'assets/' prefix
		}
		
		// Check if it's an SVG file
		if (assetPath.toLowerCase().endsWith('.svg')) {
			return SvgPicture.asset(
				assetPath,
				fit: fit,
				width: width,
				height: height,
				placeholderBuilder: (context) => Container(
					width: width,
					height: height,
					color: Colors.grey.shade100,
					child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
				),
			);
		}
		
		// For raster images (PNG, JPEG, etc.), use Image.asset
		return Image.asset(
			assetPath,
			fit: fit,
			width: width,
			height: height,
			errorBuilder: (context, error, stackTrace) {
				// Return custom error widget or default with path info
				if (errorWidget != null) {
					return errorWidget;
				}
				
				return _buildErrorWidget(assetPath, path);
			},
		);
	}
	
	/// Build a consistent error widget for both SVG and raster images
	static Widget _buildErrorWidget(String assetPath, String originalPath) {
		return Container(
			color: Colors.grey.shade200,
			padding: EdgeInsets.zero,
			alignment: Alignment.center,
			child: kDebugMode && assetPath.length < 25
					? Column(
							mainAxisAlignment: MainAxisAlignment.center,
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(Icons.broken_image, color: Colors.grey.shade400, size: 20),
								const SizedBox(height: 2),
								Text(
									assetPath,
									style: TextStyle(
										color: Colors.grey.shade600,
										fontSize: 7,
									),
									textAlign: TextAlign.center,
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
								),
							],
						)
					: Icon(Icons.broken_image, color: Colors.grey.shade400, size: 20),
		);
	}
}

