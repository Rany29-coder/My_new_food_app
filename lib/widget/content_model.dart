class UnboardingContent {
  String image;
  String title;
  String description;
  UnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}
List<UnboardingContent> contents = [
  UnboardingContent(
    image: "images/board1.png",
    title: "اهلا بيك في مهمة انقاذ الطعام",
    description: " مبسوطين جدا انك هتشاركنا في رحلة انقاذ الطعام من الهدر و تقدر توفر فلوسك.",
  ),
  UnboardingContent(
    image: "images/board2.png",
    title: "الابليكيشن بسيط",
    description: "هنمشي معاك حطوة بحطوة عشان تعرف تستمع بالتجربة و متحمسين ان احنا في الرحلة دي سوا",
  )
];
