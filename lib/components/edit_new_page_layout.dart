import 'package:daily_planner/styles/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditNewPageLayout extends StatefulWidget {
  const EditNewPageLayout({Key? key}) : super(key: key);

  @override
  _EditNewPageLayoutState createState() => _EditNewPageLayoutState();
}

class _EditNewPageLayoutState extends State<EditNewPageLayout> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '''
noun
the main body of matter in a manuscript, book, newspaper, etc., as distinguished from notes, appendixes, headings, illustrations, etc.

the original words of an author or speaker, as opposed to a translation, paraphrase, commentary, or the like:
The newspaper published the whole text of the speech.

SEE MORE
verb (used without object)Digital Technology.
to send a text me
''');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 575, child: NoteLikeTextField(controller: _controller)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 141,
              height: 72,
              child: Text(
                "What time do you want to put the task on?",
                style: MyTextStyles.taskEditingStyle,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(color: const Color(0xCCF2F2F3)),
              child: SizedBox(
                width: 200,
                height: 25,
                child: Text(
                  "12:00 PM today",
                  textAlign: TextAlign.center,
                  style: MyTextStyles.taskEditingStyle,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class NoteLikeTextField extends StatelessWidget {
  const NoteLikeTextField({
    super.key,
    required TextEditingController controller,
  }) : _controller = controller;

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // a text view with 22 lines underscored with a line
        Positioned(
          left: 16,
          right: 16,
          bottom: 10,
          child: TextField(
            maxLength: 650,
            style: MyTextStyles.taskEditingStyle,
            scrollPhysics: const NeverScrollableScrollPhysics(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Type your task here',
            ),
            // space between lines
            strutStyle: const StrutStyle(
              height: 1.3,
            ),
            maxLines: 20,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            controller: _controller,
          ),
        ),

        for (var i = 0; i < 20; i++)
          Positioned(
            left: 16,
            right: 16,
            bottom: i * 26.0 + 40,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: Color(0xA6000000),
            ),
          ),
      ],
    );
  }
}
