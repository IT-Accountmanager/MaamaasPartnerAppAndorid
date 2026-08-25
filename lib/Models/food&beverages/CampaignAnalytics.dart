class CampaignAnalytics {
  final int campaignId;
  final String campaignName;
  final int totalDelivered;
  final int totalViews;
  final int uniqueViewers;
  final int totalLikes;
  final int totalShares;
  final int totalDismissals;
  final int totalLeads;
  final double viewRate;
  final double likeRate;
  final double avgViewDuration;
  final double avgScrollDepth;
  final Map<String, int> interactionBreakdown;

  CampaignAnalytics({
    required this.campaignId,
    required this.campaignName,
    required this.totalDelivered,
    required this.totalViews,
    required this.uniqueViewers,
    required this.totalLikes,
    required this.totalShares,
    required this.totalDismissals,
    required this.totalLeads,
    required this.viewRate,
    required this.likeRate,
    required this.avgViewDuration,
    required this.avgScrollDepth,
    required this.interactionBreakdown,
  });

  factory CampaignAnalytics.fromJson(Map<String, dynamic> json) {
    return CampaignAnalytics(
      campaignId: json['campaignId'] ?? 0,
      campaignName: json['campaignName'] ?? '',
      totalDelivered: json['totalDelivered'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      uniqueViewers: json['uniqueViewers'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      totalDismissals: json['totalDismissals'] ?? 0,
      totalLeads: json['totalLeads'] ?? 0,
      viewRate: (json['viewRate'] ?? 0).toDouble(),
      likeRate: (json['likeRate'] ?? 0).toDouble(),
      avgViewDuration: (json['avgViewDuration'] ?? 0).toDouble(),
      avgScrollDepth: (json['avgScrollDepth'] ?? 0).toDouble(),
      interactionBreakdown:
      Map<String, int>.from(json['interactionBreakdown'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaignId': campaignId,
      'campaignName': campaignName,
      'totalDelivered': totalDelivered,
      'totalViews': totalViews,
      'uniqueViewers': uniqueViewers,
      'totalLikes': totalLikes,
      'totalShares': totalShares,
      'totalDismissals': totalDismissals,
      'totalLeads': totalLeads,
      'viewRate': viewRate,
      'likeRate': likeRate,
      'avgViewDuration': avgViewDuration,
      'avgScrollDepth': avgScrollDepth,
      'interactionBreakdown': interactionBreakdown,
    };
  }
}