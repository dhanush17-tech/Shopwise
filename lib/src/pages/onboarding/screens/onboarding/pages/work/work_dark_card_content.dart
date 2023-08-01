import 'package:flutter/material.dart';

 
class WorkDarkCardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                "https://image.freepik.com/free-vector/economics-finance-online-service-smartphone-screen-investment-consultation-audit-business-capital-lending-vector-illustration-set_277904-6887.jpg",
              ),
              fit: BoxFit.fill)),
    );
  }
}
