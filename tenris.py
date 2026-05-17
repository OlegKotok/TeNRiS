import pygame
import random
import os
import sys
import struct

def resource_path(relative_path):
    """ Get absolute path to resource, works for dev and for PyInstaller """
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

# Constants
SCREEN_WIDTH = 400
SCREEN_HEIGHT = 600
GRID_WIDTH = 16
GRID_HEIGHT = 24
CELL_SIZE = 25

# Colors (Converted from Pascal BGR Hex to RGB)
# Active Figure (Green)
COL_FIG_TL = (0, 255, 0)
COL_FIG_TR = (0, 255, 0)
COL_FIG_BL = (58, 190, 65)
COL_FIG_BR = (72, 149, 87)

# Normal Blocks (Pink to Red gradient)
COL_NORM_TL = (255, 0, 170)
COL_NORM_TR = (255, 96, 170)
COL_NORM_BL = (255, 128, 0)
COL_NORM_BR = (255, 0, 0)

# Marked Blocks (Yellow gradient)
COL_MARK_TL = (255, 255, 128)
COL_MARK_TR = (255, 255, 160)
COL_MARK_BL = (255, 255, 0)
COL_MARK_BR = (255, 255, 0)

class TenrisGame:
    def __init__(self, headless=False):
        self.headless = headless
        if not headless:
            pygame.init()
            self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
            pygame.display.set_caption("TeNRiS II")
            self.clock = pygame.time.Clock()
        
        self.load_assets()
        self.reset_game()
        
    def load_assets(self):
        if self.headless:
            self.bg_image = None
            self.logo = None
            self.font_main = None
            self.font_score = None
            self.sounds = {k: None for k in ['rot', 'move', 'clear', 'down', 'rotate_key', 'hit']}
            self.figures_templates = self.load_figures_dat()
            return

        # Load background
        try:
            self.bg_image = pygame.image.load(resource_path(os.path.join("texture", "picture.jpg"))).convert()
            self.bg_image = pygame.transform.scale(self.bg_image, (SCREEN_WIDTH, SCREEN_HEIGHT))
        except:
            self.bg_image = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
            self.bg_image.fill((0, 0, 50))
        
        # Load logo
        try:
            self.logo = pygame.image.load(resource_path(os.path.join("texture", "logo.bmp"))).convert()
            # User request: use white as transparent
            self.logo.set_colorkey((255, 255, 255))
            self.logo = pygame.transform.scale(self.logo, (150, 80))
        except:
            self.logo = None
            
        # Fonts with heavy fallback
        self.font_main = None
        self.font_score = None
        if pygame.font.get_init():
            try:
                self.font_main = pygame.font.SysFont("Comic Sans MS", 16, bold=True)
                self.font_score = pygame.font.SysFont("Arial", 20, bold=True)
            except:
                pass
            
            if not self.font_main:
                try:
                    self.font_main = pygame.font.SysFont(None, 24)
                    self.font_score = pygame.font.SysFont(None, 30)
                except:
                    print("Warning: Could not initialize any fonts.")
        
        # Sounds
        try:
            pygame.mixer.init()
        except:
            pass
            
        self.sounds = {}
        sound_map = {
            'rot': "buh.wav",
            'move': "move.wav",
            'clear': "clear.wav",
            'down': "down.wav",
            'rotate_key': "rotate.wav",
            'hit': "hit.wav",
        }
        for key, filename in sound_map.items():
            try:
                if pygame.mixer.get_init():
                    self.sounds[key] = pygame.mixer.Sound(resource_path(os.path.join("sounds", filename)))
                else:
                    self.sounds[key] = None
            except:
                self.sounds[key] = None
        
        try:
            if pygame.mixer.get_init():
                pygame.mixer.music.load(resource_path(os.path.join("sounds", "crasy frog.mid")))
                pygame.mixer.music.play(-1)
        except:
            pass

        self.figures_templates = self.load_figures_dat()

    def load_figures_dat(self):
        figures = []
        try:
            with open(resource_path("figures.dat"), "r") as f:
                content = f.read().split()
                if not content: return [[[0,1,0],[1,1,1],[0,0,0]]]
                count = int(content[0])
                idx = 1
                for _ in range(count):
                    fig = []
                    for _ in range(3):
                        row = [int(content[idx]), int(content[idx+1]), int(content[idx+2])]
                        fig.append(row)
                        idx += 3
                    figures.append(fig)
        except:
            figures = [[[0,1,0],[1,1,1],[0,0,0]]]
        return figures

    def reset_game(self):
        # 1-indexed map equivalent (1..16, 1..26 in Pascal)
        # We use 0-indexed internally but 16x26 grid
        self.map = [[0 for _ in range(27)] for _ in range(17)]
        self.metki = [[False for _ in range(27)] for _ in range(17)]
        self.score = 0
        self.testis = False
        self.game_over = False
        
        # High score
        self.high_score = 200
        if os.path.exists("record.dat"):
            try:
                with open("record.dat", "rb") as f:
                    self.high_score = struct.unpack("<H", f.read(2))[0]
            except:
                pass
        
        self.spawn_figure()

    def spawn_figure(self):
        template = random.choice(self.figures_templates)
        # Transpose template for easier rotation logic consistency with Pascal [x,y]
        self.current_fig = [[0 for _ in range(4)] for _ in range(4)] # 1-indexed feel
        for y in range(3):
            for x in range(3):
                if template[y][x] == 1:
                    # Original logic: s:=Random(9)+1; tetr[x, y]:=s;
                    self.current_fig[x+1][y+1] = random.randint(1, 9)
        self.fig_sx = 7
        self.fig_sy = -2
        if self.check_fishka(self.fig_sx, self.fig_sy):
            self.game_over = True

    def check_fishka(self, sx, sy, tetr=None):
        if tetr is None: tetr = self.current_fig
        for x in range(1, 4):
            for y in range(1, 4):
                if tetr[x][y] > 0:
                    mx, my = sx + x, sy + y
                    if mx < 1 or mx > 16 or my > 24: return True
                    if my >= 1 and self.map[mx][my] > 0: return True
        return False

    def rotate(self):
        t = [row[:] for row in self.current_fig]
        # Replicating Pascal Rot exactly
        c1 = t[1][2]; t[1][2] = t[2][1]
        c2 = t[2][3]; t[2][3] = c1
        c1 = t[3][2]; t[3][2] = c2
        t[2][1] = c1

        c1 = t[1][3]; t[1][3] = t[1][1]
        c2 = t[3][3]; t[3][3] = c1
        c1 = t[3][1]; t[3][1] = c2
        t[1][1] = c1

        if not self.check_fishka(self.fig_sx, self.fig_sy, t):
            self.current_fig = t
            self.play_sound('rot', self.fig_sx)

    def move_left(self):
        if self.fig_sx >= 0 and not self.check_fishka(self.fig_sx - 1, self.fig_sy):
            self.fig_sx -= 1
            self.play_sound('move', self.fig_sx)

    def move_right(self):
        if self.fig_sx < 14 and not self.check_fishka(self.fig_sx + 1, self.fig_sy):
            self.fig_sx += 1
            self.play_sound('move', self.fig_sx)

    def move_down(self, megadown=False):
        if megadown:
            while not (self.check_fishka(self.fig_sx, self.fig_sy + 1) or self.check_lim()):
                self.fig_sy += 1
            self.copy_to_map()
            self.spawn_figure()
        else:
            if not (self.check_fishka(self.fig_sx, self.fig_sy + 1) or self.check_lim()):
                self.fig_sy += 1
            else:
                self.copy_to_map()
                self.spawn_figure()

    def check_lim(self):
        for x in range(1, 4):
            for y in range(1, 4):
                if self.current_fig[x][y] > 0 and (self.fig_sy + y) > 24:
                    return True
        return False

    def copy_to_map(self):
        for x in range(1, 4):
            for y in range(1, 4):
                if self.current_fig[x][y] > 0:
                    mx, my = self.fig_sx + x, self.fig_sy + y
                    if 1 <= mx <= 16 and 1 <= my <= 26:
                        self.map[mx][my] = self.current_fig[x][y]
        self.play_sound('down', self.fig_sx)
        self.testis = True
        self.test_logic()

    def padenie(self, x0, y0):
        nap = [[False for _ in range(28)] for _ in range(18)]
        nap[x0][y0] = True
        # Flood fill connectivity logic from Pascal
        for _ in range(200): # 1000 in Pascal, 200 is plenty for 16x26
            found_any = False
            for y in range(1, 27):
                for x in range(1, 17):
                    if nap[x][y]:
                        for dx, dy in [(1,0), (-1,0), (0,1), (0,-1)]:
                            nx, ny = x + dx, y + dy
                            if 1 <= nx <= 16 and 1 <= ny <= 26:
                                if not nap[nx][ny] and self.map[nx][ny] > 0:
                                    nap[nx][ny] = True
                                    found_any = True
            if not found_any: break

        ymin = 0
        for y in range(1, 27):
            for x in range(1, 17):
                if nap[x][y] and y > ymin: ymin = y
        
        if ymin < 24:
            can_move = True
            for y in range(1, 27):
                for x in range(1, 17):
                    if nap[x][y]:
                        if not nap[x][y+1] and self.map[x][y+1] > 0:
                            can_move = False
                            break
                if not can_move: break
            
            if can_move:
                for y in range(26, 1, -1):
                    for x in range(1, 17):
                        if nap[x][y-1]:
                            self.map[x][y] = self.map[x][y-1]
                            self.map[x][y-1] = 0
                self.play_sound('hit', x0)
                return True
        return False

    def test_logic(self):
        # 1. Clear marked
        for x in range(1, 17):
            for y in range(1, 27):
                if self.metki[x][y]:
                    self.map[x][y] = 0
                    self.metki[x][y] = False

        # 2. Gravity
        for y in range(1, 26):
            for x in range(1, 17):
                if self.map[x][y] > 0:
                    self.padenie(x, y)

        # 3. Sum to 10
        for x in range(1, 16):
            for y in range(1, 26):
                if self.map[x][y] != 0:
                    # Horizontal
                    if self.map[x+1][y] != 0 and (self.map[x][y] + self.map[x+1][y] == 10):
                        self.metki[x][y] = True
                        self.metki[x+1][y] = True
                        self.score += 10
                        self.play_sound('clear', x)
                    # Vertical
                    if self.map[x][y+1] != 0 and (self.map[x][y] + self.map[x][y+1] == 10):
                        self.metki[x][y] = True
                        self.metki[x][y+1] = True
                        self.score += 10
                        self.play_sound('clear', x)
        
        # Game Over Check
        for i in range(1, 17):
            if self.map[i][1] > 0:
                self.game_over = True
        
        if self.score > self.high_score:
            self.high_score = self.score

    def draw_gradient_rect(self, rect, c_tl, c_tr, c_bl, c_br):
        # Approximation of 4-corner gradient
        # Pygame 2.x doesn't have native 4-corner gradient, we'll do a simple vertical one
        # which covers most of the look.
        for i in range(rect.height):
            ratio = i / rect.height
            r = int(c_tl[0] * (1 - ratio) + c_bl[0] * ratio)
            g = int(c_tl[1] * (1 - ratio) + c_bl[1] * ratio)
            b = int(c_tl[2] * (1 - ratio) + c_bl[2] * ratio)
            pygame.draw.line(self.screen, (r, g, b), (rect.x, rect.y + i), (rect.x + rect.width, rect.y + i))

    def draw_block(self, x_grid, y_grid, c_tl, c_tr, c_bl, c_br, val, txt_col=(255,255,255)):
        if self.headless or not self.screen: return
        px = (x_grid * 25 - 25)
        py = (y_grid * 25 - 25)
        rect = pygame.Rect(px + 1, py, 24, 24)
        self.draw_gradient_rect(rect, c_tl, c_tr, c_bl, c_br)
        pygame.draw.rect(self.screen, (0, 0, 0), (px, py, 25, 25), 1)
        
        if self.font_main:
            txt_surf = self.font_main.render(str(val), True, txt_col)
            self.screen.blit(txt_surf, (px + 6, py - 2))

    def play_sound(self, key, sx=None):
        sound = self.sounds.get(key)
        if not sound: return
        
        if sx is not None:
            # Simulate 3D Panning: soundX:=((sx-8)+0.5)/6;
            # Map sx (1..16) to pan (-1.0 .. 1.0)
            # sx=1 -> -1.0, sx=16 -> 1.0 approx
            pan = (sx - 8.5) / 7.5
            left = max(0.0, min(1.0, 1.0 - pan))
            right = max(0.0, min(1.0, 1.0 + pan))
            channel = pygame.mixer.find_channel()
            if channel:
                channel.set_volume(left, right)
                channel.play(sound)
        else:
            sound.play()

    def update_logo_anim(self):
        # time:=time+1;
        # If (time>=5) and (time<=55) then logo_transp:=5*(time-5);
        # If (time>130) and (time<=180) then logo_transp:=250-5*(time-130);
        # If time>=3000 then time:=0;
        self.logo_time += 1
        if 5 <= self.logo_time <= 55:
            self.logo_alpha = 5 * (self.logo_time - 5)
        elif 130 < self.logo_time <= 180:
            self.logo_alpha = 250 - 5 * (self.logo_time - 130)
        elif self.logo_time > 3000: # Match original Pascal timing
            self.logo_time = 0
            self.logo_alpha = 0
        else:
            if self.logo_time < 5: self.logo_alpha = 0
            # between 55 and 130 it stays at 250ish

    def draw(self):
        if self.headless or not self.screen: return
        self.screen.blit(self.bg_image, (0, 0))
        
        # Draw logo with alpha
        if self.logo:
            # Pygame 2 surface alpha
            self.logo.set_alpha(self.logo_alpha)
            self.screen.blit(self.logo, (SCREEN_WIDTH - 151, SCREEN_HEIGHT - 83))
        
        # Field
        for y in range(1, 27):
            for x in range(1, 17):
                if self.map[x][y] > 0:
                    if self.metki[x][y]:
                        # Marked blocks: blue text on yellow: $0000ff -> (255, 0, 0) in BGR? No, text color was (0,0,255)
                        self.draw_block(x, y, COL_MARK_TL, COL_MARK_TR, COL_MARK_BL, COL_MARK_BR, self.map[x][y], (0, 0, 255))
                    else:
                        # Normal blocks: white text on pink: $FFFFFF -> (255,255,255)
                        self.draw_block(x, y, COL_NORM_TL, COL_NORM_TR, COL_NORM_BL, COL_NORM_BR, self.map[x][y], (255, 255, 255))
        
        # Figure
        for x in range(1, 4):
            for y in range(1, 4):
                if self.current_fig[x][y] > 0:
                    my = self.fig_sy + y
                    if my >= 1:
                        # Active figure: yellow text on green: $FFFF80 -> (255, 255, 128)
                        self.draw_block(self.fig_sx + x, my, COL_FIG_TL, COL_FIG_TR, COL_FIG_BL, COL_FIG_BR, self.current_fig[x][y], (255, 255, 128))

        # UI
        if self.font_score:
            score_surf = self.font_score.render(f"Score: {self.score}", True, (255, 0, 255))
            self.screen.blit(score_surf, (285, 20))
        
        if self.font_main:
            high_surf = self.font_main.render(f"top score: {self.high_score}", True, (0, 255, 0))
            self.screen.blit(high_surf, (5, 5))
            
            if self.game_over:
                msg = self.font_score.render("GAME OVER - Press R", True, (255, 255, 255))
                if msg: self.screen.blit(msg, (100, 300))

        pygame.display.flip()

    def run(self):
        game_timer = pygame.USEREVENT + 1
        pygame.time.set_timer(game_timer, 750)
        
        self.logo_time = 0
        self.logo_alpha = 0
        
        running = True
        while running:
            self.update_logo_anim()
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                elif event.type == game_timer:
                    if not self.game_over:
                        self.move_down()
                        if self.testis:
                            self.test_logic()
                            self.testis = False
                
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_ESCAPE: running = False
                    if event.key == pygame.K_r: self.reset_game()
                    if not self.game_over:
                        if event.key == pygame.K_UP: self.rotate()
                        elif event.key == pygame.K_LEFT: 
                            self.move_left()
                            self.play_sound('move', self.fig_sx)
                        elif event.key == pygame.K_RIGHT: 
                            self.move_right()
                            self.play_sound('move', self.fig_sx)
                        elif event.key == pygame.K_SPACE: 
                            self.move_down(megadown=True)
                        elif event.key == pygame.K_DOWN:
                            self.play_sound('rotate_key', self.fig_sx)
                            self.move_down(); self.move_down(); self.move_down()
                        elif event.key == pygame.K_s:
                            if pygame.mixer.music.get_busy(): pygame.mixer.music.stop()
                            else: pygame.mixer.music.play(-1)

            self.draw()
            self.clock.tick(60)

        # Save record
        if self.score > self.high_score:
            with open("record.dat", "wb") as f:
                f.write(struct.pack("<H", self.score))

        pygame.quit()

if __name__ == "__main__":
    headless = "--headless" in sys.argv
    game = TenrisGame(headless=headless)
    game.run()
