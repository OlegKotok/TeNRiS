import pygame

class NeonPuzzlerTheme:
    def __init__(self):
        self.name = "Neon Puzzler"
        
        # Cyberpunk/Neon Palette
        # Active: Electric Lime with Glow
        self.COL_FIG_TL = (204, 255, 0)
        self.COL_FIG_TR = (150, 255, 0)
        self.COL_FIG_BL = (100, 200, 0)
        self.COL_FIG_BR = (50, 150, 0)

        # Static: Deep Cyber Grape to Neon Crimson
        self.COL_NORM_TL = (77, 0, 140)
        self.COL_NORM_TR = (120, 0, 100)
        self.COL_NORM_BL = (180, 0, 85)
        self.COL_NORM_BR = (255, 0, 85)

        # Marked: Cyan Blizzard Pulse
        self.COL_MARK_TL = (0, 242, 255)
        self.COL_MARK_TR = (0, 200, 255)
        self.COL_MARK_BL = (0, 150, 255)
        self.COL_MARK_BR = (0, 100, 255)
        
        self.TEXT_FIG = (255, 255, 255) # Pure white for lime contrast
        self.TEXT_NORM = (230, 230, 255)
        self.TEXT_MARK = (255, 255, 255)
        self.TEXT_SCORE = (0, 255, 255)
        self.TEXT_HIGH = (204, 255, 0)

    def get_fonts(self):
        # Geometric and Technical
        return {
            "main": ("Futura", 18, True), # Geometric fallback to sans-serif
            "score": ("Impact", 24, False)
        }

    def draw_block_background(self, screen, rect):
        # Modern glass effect: thin inner glow
        inner_rect = rect.inflate(-2, -2)
        pygame.draw.rect(screen, (255, 255, 255), rect, 1) # Subtle white border
        # The main gradient is drawn by tenris.py, but we could add 
        # a semi-transparent overlay here for the "glass" look
        glass_overlay = pygame.Surface((rect.width, rect.height), pygame.SRCALPHA)
        glass_overlay.fill((255, 255, 255, 30)) # 30/255 opacity white sheen
        screen.blit(glass_overlay, rect.topleft)

    def apply_effects(self, screen):
        # Atmospheric scanlines effect
        for y in range(0, 600, 3):
            pygame.draw.line(screen, (0, 0, 0, 40), (0, y), (400, y))
