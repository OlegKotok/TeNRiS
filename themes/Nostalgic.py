import pygame

class NostalgicTheme:
    def __init__(self):
        self.name = "Nostalgic"
        
        # Original Colors (RGB)
        self.COL_FIG_TL = (0, 255, 0)
        self.COL_FIG_TR = (0, 255, 0)
        self.COL_FIG_BL = (58, 190, 65)
        self.COL_FIG_BR = (72, 149, 87)

        self.COL_NORM_TL = (255, 0, 170)
        self.COL_NORM_TR = (255, 96, 170)
        self.COL_NORM_BL = (255, 128, 0)
        self.COL_NORM_BR = (255, 0, 0)

        self.COL_MARK_TL = (255, 255, 128)
        self.COL_MARK_TR = (255, 255, 160)
        self.COL_MARK_BL = (255, 255, 0)
        self.COL_MARK_BR = (255, 255, 0)
        
        self.TEXT_FIG = (255, 255, 128)
        self.TEXT_NORM = (255, 255, 255)
        self.TEXT_MARK = (0, 0, 255)
        self.TEXT_SCORE = (255, 0, 255)
        self.TEXT_HIGH = (0, 255, 0)

    def get_fonts(self):
        # Comic Sans soul
        return {
            "main": ("Comic Sans MS", 16, True),
            "score": ("Arial", 20, True)
        }

    def draw_block_background(self, screen, rect):
        # Original logic: solid gradient then border
        pass # tenris.py handles the standard gradient draw

    def apply_effects(self, screen):
        pass
