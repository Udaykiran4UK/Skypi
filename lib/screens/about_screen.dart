import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('About', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.green)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to SKYPI: Empowering Technical Excellence',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'SKYPI is a pioneering platform that revolutionizes the way students acquire technical skills, bridging the chasm between academic theory and real-world application. Our mission is to cultivate a community of innovators, equipped with the expertise and confidence to tackle complex challenges and propel the tech industry forward.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Unlock Your Potential with SKYPI',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Our platform presents daily technical tasks, meticulously crafted to stimulate critical thinking and problem-solving prowess. Students submit their solutions, which are meticulously reviewed by our expert panel, providing constructive feedback and precise evaluations. This iterative process fosters continuous improvement, as students receive personalized assessments and actionable insights to refine their skills.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Transformative Benefits for Students',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '- Develop razor-sharp problem-solving skills\n'
                    '- Enhance technical expertise through hands-on experience\n'
                    '- Amplify confidence and self-assurance\n'
                    '- Curate a portfolio of projects showcasing mastery\n'
                    '- Gain visibility among top employers seeking exceptional talent',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Empowering Educators, Enhancing Outcomes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'SKYPI supports educators with:\n'
                    '- Comprehensive teaching materials and resources\n'
                    '- Automated grading and feedback mechanisms\n'
                    '- Data-driven class tracking and analytics\n'
                    '- Customizable task creation aligned with curriculum goals\n'
                    '- Seamless integration with existing educational frameworks',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'SKYPI Features: Designed for Excellence',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '- Task library with calibrated difficulty levels\n'
                    '- Real-world project-based tasks mirroring industry scenarios\n'
                    '- Peer review and discussion forums for collaborative growth\n'
                    '- Personalized learning pathways tailored to individual needs\n'
                    '- Integration with leading coding platforms for seamless development',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'SKYPI: Elevate Your Technical Horizon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                    '- SKYPI: Where Theory Meets Practice\n'
                    '- SKYPI: Igniting Technical Brilliance\n'
                    '- SKYPI: Transforming Minds, Enhancing Skills',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
