import unittest

from app import triage


class TriageSafetyOverrideTests(unittest.TestCase):
    def test_lethal_stabbing_overrides_model_routing(self):
        result = triage(
            "This is a lethal stabbing dispute. My neighbor stabbed someone."
        )

        self.assertEqual(result["category"], "Physical Injury/Threats")
        self.assertEqual(result["urgency"], "Immediate Intervention")
        self.assertFalse(result["eligible"])
        self.assertIn("emergency", result["recommended_action"].lower())
        self.assertTrue(result["needs_staff_review"])
        self.assertTrue(result["rule_reasons"])


if __name__ == "__main__":
    unittest.main()
