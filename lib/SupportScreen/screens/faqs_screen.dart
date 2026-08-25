import 'package:flutter/material.dart';
import '../models/support_models.dart';
import '../models/faq_data.dart';
import '../widgets/theme.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});
  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  String _activeCategory = 'all';
  String _searchQuery = '';
  final Set<int> _expanded = {};
  int? _emailRequestFaqId;

  final _searchCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _additionalCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _emailCtrl.dispose();
    _additionalCtrl.dispose();
    super.dispose();
  }

  List<FaqItem> get _filtered => staticFaqs.where((f) {
    final matchCat = _activeCategory == 'all' || f.category == _activeCategory;
    final q = _searchQuery.toLowerCase();
    final matchSearch =
        q.isEmpty ||
        f.question.toLowerCase().contains(q) ||
        f.answer.toLowerCase().contains(q) ||
        f.tags.any((t) => t.toLowerCase().contains(q));
    return matchCat && matchSearch;
  }).toList();

  int _categoryCount(String id) => id == 'all'
      ? staticFaqs.length
      : staticFaqs.where((f) => f.category == id).length;

  void _submitEmailRequest() {
    if (_emailCtrl.text.trim().isEmpty) {
      spSnack(context, 'Enter your email', warn: true);
      return;
    }
    final faq = staticFaqs.firstWhere(
      (f) => f.id == _emailRequestFaqId,
      orElse: () =>
          const FaqItem(id: 0, question: '', answer: '', category: ''),
    );
    spSnack(
      context,
      'Email request sent for: "${faq.question.length > 30 ? faq.question.substring(0, 30) + '...' : faq.question}"',
    );
    setState(() {
      _emailRequestFaqId = null;
      _emailCtrl.clear();
      _additionalCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Search bar
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: spBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 16, color: spText3),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search FAQs...',
                    hintStyle: TextStyle(color: spText3, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13, color: spText1),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: spText3,
                  ),
                ),
            ],
          ),
        ),
      ),

      // Category chips
      SizedBox(
        height: 88,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          itemCount: faqCategories.length,
          itemBuilder: (_, i) {
            final cat = faqCategories[i];
            final isActive = _activeCategory == cat['id'];
            return GestureDetector(
              onTap: () =>
                  setState(() => _activeCategory = cat['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? Color(cat['color'] as int).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive ? Color(cat['color'] as int) : spBorder,
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Color(cat['color'] as int).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(cat['color'] as int),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          cat['icon'] as String,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['name'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Color(cat['color'] as int) : spText2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_categoryCount(cat['id'] as String)}',
                      style: TextStyle(
                        fontSize: 8,
                        color: isActive ? Color(cat['color'] as int) : spText3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // Results label
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Row(
          children: [
            const Icon(Icons.support_agent_rounded, size: 16, color: spAccent),
            const SizedBox(width: 6),
            Text(
              _activeCategory == 'all'
                  ? 'All FAQs'
                  : faqCategories.firstWhere(
                          (c) => c['id'] == _activeCategory,
                          orElse: () => {'name': 'FAQs'},
                        )['name']
                        as String,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: spText1,
              ),
            ),
            const Spacer(),
            Text(
              '${_filtered.length} results',
              style: const TextStyle(fontSize: 11, color: spText2),
            ),
          ],
        ),
      ),

      // FAQ list
      Expanded(
        child: _filtered.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔍', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 12),
                    Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: spText1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Try a different search or category.',
                      style: TextStyle(color: spText2, fontSize: 12),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _faqItem(_filtered[i]),
              ),
      ),
    ],
  );

  Widget _faqItem(FaqItem faq) {
    final isExpanded = _expanded.contains(faq.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? spAccent.withOpacity(0.4) : spBorder,
        ),
        boxShadow: [
          BoxShadow(color: spShadow, blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          // Question row
          GestureDetector(
            onTap: () => setState(
              () =>
                  isExpanded ? _expanded.remove(faq.id) : _expanded.add(faq.id),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  const Text('❓', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            faq.question,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: spText1,
                            ),
                          ),
                        ),
                        if (faq.popular)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: spAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Popular',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: spText3,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Answer + email form
          if (isExpanded) ...[
            const Divider(color: spBorder, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faq.answer,
                    style: const TextStyle(
                      fontSize: 13,
                      color: spText2,
                      height: 1.6,
                    ),
                  ),
                  // Tags
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: faq.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: spBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: spBorder),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 10,
                                color: spText2,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // Email request
                  if (_emailRequestFaqId == faq.id) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: spBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: spBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 15,
                                color: spAccent,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Request More Details via Email',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: spText1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _miniField(
                            _emailCtrl,
                            'Your email address *',
                            TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 8),
                          _miniField(
                            _additionalCtrl,
                            'Additional details (optional)',
                            TextInputType.text,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _submitEmailRequest,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: spAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Send Request',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _emailRequestFaqId = null),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: spGrayL,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: spBorder),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: spText2,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    // GestureDetector(
                    //   onTap: () => setState(() {
                    //     _emailRequestFaqId = faq.id;
                    //     _emailCtrl.clear();
                    //     _additionalCtrl.clear();
                    //   }),
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 12,
                    //       vertical: 8,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(8),
                    //       border: Border.all(color: spAccent),
                    //     ),
                    //     child: const Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Icon(
                    //           Icons.email_outlined,
                    //           size: 13,
                    //           color: spAccent,
                    //         ),
                    //         SizedBox(width: 6),
                    //         Text(
                    //           'Still need help? Request email assistance',
                    //           style: TextStyle(
                    //             color: spAccent,
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniField(
    TextEditingController ctrl,
    String hint,
    TextInputType kt, {
    int maxLines = 1,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: spBorder),
    ),
    child: TextField(
      controller: ctrl,
      keyboardType: kt,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: spText3, fontSize: 12),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(10),
      ),
      style: const TextStyle(fontSize: 12, color: spText1),
    ),
  );
}
