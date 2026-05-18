import unittest
import os
from tenris import TenrisGame

class TestTenrisLogic(unittest.TestCase):
    def setUp(self):
        # Initialize in headless mode to test logic without GUI dependencies
        self.game = TenrisGame(headless=True)

    def test_sum_to_10_horizontal(self):
        # Clear map
        self.game.map = [[0 for _ in range(27)] for _ in range(17)]
        # Place two blocks that sum to 10
        self.game.map[5][10] = 3
        self.game.map[6][10] = 7
        self.game.test_logic()
        # They should be cleared (map value becomes 0)
        self.assertEqual(self.game.map[5][10], 0)
        self.assertEqual(self.game.map[6][10], 0)
        self.assertEqual(self.game.score, 10)

    def test_sum_to_10_vertical(self):
        self.game.map = [[0 for _ in range(27)] for _ in range(17)]
        self.game.map[5][10] = 4
        self.game.map[5][11] = 6
        self.game.test_logic()
        self.assertEqual(self.game.map[5][10], 0)
        self.assertEqual(self.game.map[5][11], 0)
        self.assertEqual(self.game.score, 10)

    def test_gravity_blob(self):
        self.game.map = [[0 for _ in range(27)] for _ in range(17)]
        # Create a floating blob
        self.game.map[5][10] = 1
        self.game.map[6][10] = 1
        self.game.map[5][11] = 1
        
        # Manually trigger gravity (padenie)
        # In Tenris, gravity is applied to every block in the grid during test_logic
        self.game.test_logic()
        
        # The blob should have moved down at least one step if there's space
        # Given the grid is empty, it should fall until it hits row 24 or a block
        # test_logic calls padenie which moves it down.
        # Let's check if it moved from (5, 10) to (5, 11) or lower
        self.assertEqual(self.game.map[5][10], 0)
        # Note: padenie moves one step per call in Pascal version's loop
        # Wait, Pascal padenie moves the WHOLE blob one step down.
        # My padenie does the same.
        self.assertGreater(self.game.map[5][24], 0) # Should have reached the bottom limit 24

    def test_collision(self):
        self.game.map = [[0 for _ in range(27)] for _ in range(17)]
        self.game.map[5][10] = 1
        # Test collision with placed block
        # current_fig is 1-indexed 4x4
        fig = [[0]*5 for _ in range(5)]
        fig[1][1] = 1
        self.assertTrue(self.game.check_fishka(4, 9, fig)) # 4+1=5, 9+1=10 -> Collision
        self.assertFalse(self.game.check_fishka(4, 8, fig)) # 4+1=5, 8+1=9 -> No collision

if __name__ == '__main__':
    unittest.main()
