import 'package:flutter/material.dart';
import '../../../utils/extension/string_extension.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'terms_and_conditions'.tr,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            _buildSection(
              'terms_introduction_title'.tr,
              'terms_introduction_content'.tr,
            ),

            // Eligibility
            _buildSection(
              'terms_eligibility_title'.tr,
              'terms_eligibility_content'.tr,
            ),

            // Account Registration & Security
            _buildSection(
              'terms_account_title'.tr,
              'terms_account_content'.tr,
            ),

            // Services Provided
            _buildSection(
              'terms_services_title'.tr,
              'terms_services_content'.tr,
            ),

            // Data Protection & Privacy
            _buildSection(
              'terms_data_title'.tr,
              'terms_data_content'.tr,
            ),

            // Third-Party Services
            _buildSection(
              'terms_third_party_title'.tr,
              'terms_third_party_content'.tr,
            ),

            // User Responsibilities
            _buildSection(
              'terms_user_responsibilities_title'.tr,
              'terms_user_responsibilities_content'.tr,
            ),

            // Intellectual Property
            _buildSection(
              'terms_intellectual_property_title'.tr,
              'terms_intellectual_property_content'.tr,
            ),

            // Limitation of Liability
            _buildSection(
              'terms_liability_title'.tr,
              'terms_liability_content'.tr,
            ),

            // Changes to These Terms
            _buildSection(
              'terms_changes_title'.tr,
              'terms_changes_content'.tr,
            ),

            // Termination
            _buildSection(
              'terms_termination_title'.tr,
              'terms_termination_content'.tr,
            ),

            // Governing Law
            _buildSection(
              'terms_governing_law_title'.tr,
              'terms_governing_law_content'.tr,
            ),

            // Contact Us
            _buildSection(
              'terms_contact_title'.tr,
              'terms_contact_content'.tr,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}