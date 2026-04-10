import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:selfiecam1/data/models/upload_queue_item.dart';
import 'package:selfiecam1/data/models/upload_status.dart';
import 'package:selfiecam1/data/services/upload_queue_service.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/presentation/component/back_button.dart';
import 'package:sizer/sizer.dart';

class PendingUploads extends StatefulWidget {
  const PendingUploads({super.key});

  @override
  State<PendingUploads> createState() => _PendingUploadsState();
}

class _PendingUploadsState extends State<PendingUploads> {
  final queue = Get.find<UploadQueueService>();

  static const int _perPage = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background ────────────────────────────────────────────────────
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              child: Image.asset(AppAssets.background1, fit: BoxFit.cover),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 100.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween
                  // ,
                  children: [
                    // Top logo
                    SizedBox(height: 3.h),
                    Align(alignment: Alignment.topLeft, child: CustomBackButton()),
                    SizedBox(
                      height: 18.h,
                      child: Center(
                        child: Image.asset(AppAssets.logo1, width: 60.w, fit: BoxFit.contain),
                      ),
                    ),

                    Text('PENDING TRANSFERS', style: textTheme.displayLarge),
                    SizedBox(height: 2.h),
                    // Table section
                    Column(
                      children: [
                        // ── Stream-driven table ───────────────────────────
                        StreamBuilder<UploadQueueItem>(
                          stream: queue.onItemUpdated,
                          builder: (context, _) {
                            // Combine all non-completed items; completed shown
                            // dimmed so the user sees the full picture.
                            final all = [...queue.pendingItems, ...queue.failedItems, ...queue.completedItems].toList()
                              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                            final pageCount = (all.length / _perPage).ceil().clamp(1, 999);
                            final safePage = _currentPage.clamp(0, pageCount - 1);
                            final pageItems = all.skip(safePage * _perPage).take(_perPage).toList();

                            return Column(
                              children: [
                                _UploadTable(items: pageItems, queue: queue),
                                SizedBox(height: 2.h),
                                if (pageCount > 1)
                                  _Pagination(
                                    currentPage: safePage,
                                    pageCount: pageCount,
                                    onPageChanged: (p) => setState(() => _currentPage = p),
                                  ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 4.h),
                        Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
                      ],
                    ),

                    // Bottom logo
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 3.h,
            right: 0,
            left: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 3.h),
              child: Image.asset(AppAssets.logo2, width: 55.w, height: 10.h, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Table
// ─────────────────────────────────────────────────────────────────────────────

class _UploadTable extends StatelessWidget {
  final List<UploadQueueItem> items;
  final UploadQueueService queue;

  const _UploadTable({required this.items, required this.queue});

  static const _headerStyle = TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.4);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E2A45).withOpacity(0.85), borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Container(
            color: const Color(0xFF162035),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: const [
                _HeaderCell('Media ID', flex: 2, sortable: true),
                // _HeaderCell('Preview', flex: 2, sortable: true),
                _HeaderCell('Contact', flex: 4, sortable: true),
                _HeaderCell('Date', flex: 2, sortable: true),
                _HeaderCell('Time', flex: 2),
                _HeaderCell('Status', flex: 2),
                _HeaderCell('Action', flex: 2, align: TextAlign.center),
              ],
            ),
          ),

          // ── Data rows ───────────────────────────────────────────────────
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('No uploads yet', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
            )
          else
            ...items.asMap().entries.map((e) => _UploadRow(item: e.value, isEven: e.key.isEven, queue: queue)),
        ],
      ),
    );
  }
}

// ── Header cell ───────────────────────────────────────────────────────────────

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final bool sortable;
  final TextAlign align;

  const _HeaderCell(this.label, {this.flex = 1, this.sortable = false, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: align == TextAlign.center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.4),
          ),
          if (sortable) ...[
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_drop_up, size: 14, color: Colors.white.withOpacity(0.5)),
                Icon(Icons.arrow_drop_down, size: 14, color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data row
// ─────────────────────────────────────────────────────────────────────────────

class _UploadRow extends StatelessWidget {
  final UploadQueueItem item;
  final bool isEven;
  final UploadQueueService queue;

  const _UploadRow({required this.item, required this.isEven, required this.queue});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').format(item.createdAt);
    final time = DateFormat('hh:mm a').format(item.createdAt);
    final contact = item.leadCapture?.email?.isNotEmpty == true
        ? item.leadCapture!.email!
        : item.leadCapture?.name?.isNotEmpty == true
        ? item.leadCapture!.name!
        : '-';

    return Container(
      color: isEven ? const Color(0xFF1E2A45).withOpacity(0.6) : const Color(0xFF243050).withOpacity(0.6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          // Media ID
          Expanded(
            flex: 2,
            child: Text('#${item.id.substring(0, 5).toUpperCase()}', style: const TextStyle(color: Colors.white, fontSize: 10)),
          ),

          // Preview thumbnail
          // Expanded(
          //   flex: 2,
          //   child: _PreviewThumb(filePath: item.filePath, mimeType: item.mimeType),
          // ),

          // Contact
          Expanded(
            flex: 4,
            child: Text(
              contact,
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Date
          Expanded(
            flex: 2,
            child: Text(date, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
          ),

          // Time
          Expanded(
            flex: 2,
            child: Text(time, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
          ),

          // Status badge
          Expanded(flex: 2, child: _StatusBadge(status: item.status)),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Retry – only shown when failed or pending
                if (item.isFailed || item.isPending)
                  GestureDetector(
                    onTap: () => queue.retry(item.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.skip_next_rounded,
                        color: item.isFailed ? const Color(0xFF4ADE80) : const Color(0xFF4ADE80).withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                  ),

                // Cancel / delete
                if (!item.isCompleted)
                  GestureDetector(
                    onTap: () => queue.cancel(item.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171), size: 20),
                    ),
                  ),

                // Uploading progress indicator
                if (item.isUploading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: item.uploadProgress,
                      strokeWidth: 2,
                      color: const Color(0xFF38BDF8),
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String mimeType) {
    if (mimeType.startsWith('image/gif')) return 'GIF';
    if (mimeType.startsWith('image/')) return 'Photo';
    if (mimeType.startsWith('video/')) return 'Video';
    return 'File';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preview thumbnail
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewThumb extends StatelessWidget {
  final String filePath;
  final String mimeType;

  const _PreviewThumb({required this.filePath, required this.mimeType});

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    final isImage = mimeType.startsWith('image/');

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 40,
        height: 40,
        child: isImage && file.existsSync()
            ? Image.file(file, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
    color: const Color(0xFF334155),
    child: const Icon(Icons.insert_drive_file_outlined, color: Colors.white54, size: 20),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final UploadStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, filled) = switch (status) {
      UploadStatus.pending => ('Pending', const Color(0xFFFBBF24), false),
      UploadStatus.uploading => ('Process', const Color(0xFF4ADE80), false),
      UploadStatus.completed => ('Done', const Color(0xFF38BDF8), false),
      UploadStatus.failed => ('Failed', const Color(0xFFF87171), true),
      UploadStatus.cancelled => ('Cancelled', const Color(0xFFF87171), true),
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.2) : Colors.transparent,
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pagination
// ─────────────────────────────────────────────────────────────────────────────

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final void Function(int) onPageChanged;

  const _Pagination({required this.currentPage, required this.pageCount, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        _PaginationButton(label: 'Previous', onTap: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null),

        const SizedBox(width: 6),

        // Page numbers – show max 5 around current
        ...List.generate(
          pageCount,
          (i) => i,
        ).where((i) => i == 0 || i == pageCount - 1 || (i - currentPage).abs() <= 1).fold<List<Widget>>([], (acc, i) {
          // Insert ellipsis gap
          if (acc.isNotEmpty) {
            final prev = int.tryParse((acc.last is _PaginationButton) ? (acc.last as _PaginationButton).label : '') ?? -99;
            if (i - prev > 1) {
              acc.add(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('…', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                ),
              );
            }
          }
          acc.add(_PaginationButton(label: '${i + 1}', active: i == currentPage, onTap: () => onPageChanged(i)));
          return acc;
        }),

        const SizedBox(width: 6),

        // Next
        _PaginationButton(label: 'Next', onTap: currentPage < pageCount - 1 ? () => onPageChanged(currentPage + 1) : null),
      ],
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _PaginationButton({required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0284C7) : const Color(0xFF1E2A45).withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? const Color(0xFF0284C7) : Colors.white.withOpacity(0.15)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDisabled ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(active ? 1 : 0.75),
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
