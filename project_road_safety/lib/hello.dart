import 'package:flutter/material.dart';
import 'navigate_screen.dart';
Widget homePage(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Color(0xFF713C5D),
      ),
      padding: EdgeInsets.only(bottom: 92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '10:10',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF541818),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://fn12.com/api/clusters/cluster-fn12-prod-asia-southeast1/projects/RcExYGpbeKotx4YB5fSimW/assets/images/0bf045dbe1129e717d0d0c861b871b2da2aff553?Expires=1711882481&KeyName=fn12-cdn&Signature=FFPHQePd8ubRZnCeLB8goO39Gjc='),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 31.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 8.4),
                  child: Text(
                    '10',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF541818),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('path/to/vector_image.png'), // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Enjoy the journey, not the destination',
            style: TextStyle(
              fontSize: 26,
              color: Color(0xFFE2CBCB),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 88),
          Text(
            'Every day is a good day\nwith safe roads',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFFE2CBCB),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            width: 260,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Color(0xFFF3D9D8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NavigatePage()), // Navigate to the map view page
                );
              },
              child: Text(
                'START NOW',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFFB77C7C),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}