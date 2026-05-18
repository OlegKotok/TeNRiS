import pygame


class DeepOceanTheme:
    def __init__(self):
        self.name = "Deep Ocean"

        # Active figure: bioluminescent aquamarine
        self.COL_FIG_TL = (0, 230, 200)
        self.COL_FIG_TR = (0, 200, 180)
        self.COL_FIG_BL = (0, 140, 130)
        self.COL_FIG_BR = (0, 90, 100)

        # Normal blocks: deep teal to indigo
        self.COL_NORM_TL = (20, 60, 120)
        self.COL_NORM_TR = (15, 80, 140)
        self.COL_NORM_BL = (10, 40, 100)
        self.COL_NORM_BR = (30, 20, 80)

        # Marked blocks: warm amber flash
        self.COL_MARK_TL = (255, 200, 50)
        self.COL_MARK_TR = (255, 180, 30)
        self.COL_MARK_BL = (220, 140, 10)
        self.COL_MARK_BR = (180, 100, 0)

        self.TEXT_FIG  = (220, 255, 255)   # icy white-cyan
        self.TEXT_NORM = (140, 210, 255)   # soft blue glow
        self.TEXT_MARK = (80, 30, 0)       # dark brown on amber
        self.TEXT_SCORE = (0, 210, 220)    # teal
        self.TEXT_HIGH  = (255, 200, 50)   # amber gold

    def get_fonts(self):
        return {
            "main":  ("Verdana", 15, False),
            "score": ("Verdana", 19, True),
        }

    def draw_block_background(self, screen, rect):
        # Subtle inner highlight — top-left corner shimmer
        highlight = pygame.Surface((rect.width, rect.height), pygame.SRCALPHA)
        pygame.draw.line(highlight, (255, 255, 255, 40), (0, 0), (rect.width, 0))
        pygame.draw.line(highlight, (255, 255, 255, 25), (0, 0), (0, rect.height))
        screen.blit(highlight, rect.topleft)

    def apply_effects(self, screen):
        # Faint deep-water vignette: darken edges
        w, h = screen.get_size()
        vignette = pygame.Surface((w, h), pygame.SRCALPHA)
        for i, alpha in [(30, 60), (20, 40), (10, 20)]:
            pygame.draw.rect(vignette, (0, 10, 30, alpha), (0, 0, w, i))           # top
            pygame.draw.rect(vignette, (0, 10, 30, alpha), (0, h - i, w, i))       # bottom
            pygame.draw.rect(vignette, (0, 10, 30, alpha), (0, 0, i, h))           # left
            pygame.draw.rect(vignette, (0, 10, 30, alpha), (w - i, 0, i, h))       # right
        screen.blit(vignette, (0, 0))
