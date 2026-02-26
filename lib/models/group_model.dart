class GroupModel {
  final String id;
  final String name;
  final String description;
  final int membersCount;
  final bool isFree;
  final double? price;
  final bool requiresApproval;
  final bool isMember;
  final String? cell;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.membersCount,
    required this.isFree,
    this.price,
    this.requiresApproval = false,
    this.isMember = false,
    this.cell,
  });

  static List<GroupModel> get mocks => [
    GroupModel(id: 'g1', name: 'Advanced React Patterns', description: 'Deep dive into advanced React patterns and best practices', membersCount: 1243, isFree: false, price: 29, cell: 'Web Development'),
    GroupModel(id: 'g2', name: 'Freelance Web Developers', description: 'Network and share opportunities with fellow freelancers', membersCount: 856, isFree: true, requiresApproval: true, cell: 'Web Development'),
    GroupModel(id: 'g3', name: 'React Native Masters', description: 'Exclusive community for React Native experts', membersCount: 2103, isFree: false, price: 49, requiresApproval: true, cell: 'Web Development'),
    GroupModel(id: 'g4', name: 'UI/UX Design Hub', description: 'Share your designs, get feedback, and grow your skills', membersCount: 3200, isFree: true, cell: 'Design', isMember: true),
    GroupModel(id: 'g5', name: 'Backend Architects', description: 'For senior backend engineers building scalable systems', membersCount: 987, isFree: false, price: 39, cell: 'Web Development'),
  ];
}
