# Makefile for TeNRiS II
# Supports Windows and Linux builds

# Compiler settings
FPC = fpc
FPCFLAGS = -Mdelphi -Scghi -O2 -g -gl

# Platform detection
ifeq ($(OS),Windows_NT)
    PLATFORM = win32
    TARGET = TeNRiS.exe
    FPCFLAGS += -Twin32 -WG
else
    PLATFORM = linux
    TARGET = TeNRiS
    FPCFLAGS += -Tlinux
endif

# Directories
SRCDIR = .
BINDIR = bin
LIBDIR = lib
OBJDIR = $(LIBDIR)/$(PLATFORM)

# Source files
MAIN_SRC = TeNRiS.lpr
UNITS = DGLEngine_header.pas

# Default target
all: $(BINDIR)/$(TARGET)

# Create directories
$(BINDIR):
	mkdir -p $(BINDIR)

$(OBJDIR):
	mkdir -p $(OBJDIR)

# Compile main executable
$(BINDIR)/$(TARGET): $(MAIN_SRC) $(UNITS) | $(BINDIR) $(OBJDIR)
	$(FPC) $(FPCFLAGS) -Fu$(SRCDIR) -FE$(BINDIR) -FU$(OBJDIR) $(MAIN_SRC)

# Copy resources
install: $(BINDIR)/$(TARGET)
	@echo "Copying game resources..."
ifeq ($(OS),Windows_NT)
	@if exist DGLEngine.dll copy DGLEngine.dll $(BINDIR)\ >nul 2>&1
	@if exist *.dat copy *.dat $(BINDIR)\ >nul 2>&1
	@if exist *.ini copy *.ini $(BINDIR)\ >nul 2>&1
	@if exist sounds xcopy sounds $(BINDIR)\sounds\ /E /I /Y >nul 2>&1
	@if exist texture xcopy texture $(BINDIR)\texture\ /E /I /Y >nul 2>&1
	@if exist girls xcopy girls $(BINDIR)\girls\ /E /I /Y >nul 2>&1
else
	@cp -f DGLEngine.dll $(BINDIR)/ 2>/dev/null || true
	@cp -f *.dat $(BINDIR)/ 2>/dev/null || true
	@cp -f *.ini $(BINDIR)/ 2>/dev/null || true
	@cp -rf sounds $(BINDIR)/ 2>/dev/null || true
	@cp -rf texture $(BINDIR)/ 2>/dev/null || true
	@cp -rf girls $(BINDIR)/ 2>/dev/null || true
endif
	@echo "Build complete: $(BINDIR)/$(TARGET)"

# Clean build files
clean:
ifeq ($(OS),Windows_NT)
	@if exist $(BINDIR) rmdir /S /Q $(BINDIR)
	@if exist $(LIBDIR) rmdir /S /Q $(LIBDIR)
else
	@rm -rf $(BINDIR) $(LIBDIR)
endif

# Run the game
run: install
	cd $(BINDIR) && ./$(TARGET)

# Debug build
debug: FPCFLAGS += -dDEBUG -Ci -Co -Cr -Ct
debug: $(BINDIR)/$(TARGET)

# Release build (optimized)
release: FPCFLAGS += -O3 -Xs
release: $(BINDIR)/$(TARGET)

# Help
help:
	@echo "TeNRiS II Build System"
	@echo "====================="
	@echo "Available targets:"
	@echo "  all      - Build the game (default)"
	@echo "  install  - Build and copy resources"
	@echo "  clean    - Remove build files"
	@echo "  run      - Build, install and run"
	@echo "  debug    - Build with debug info"
	@echo "  release  - Build optimized version"
	@echo "  help     - Show this help"
	@echo ""
	@echo "Platform: $(PLATFORM)"
	@echo "Target:   $(TARGET)"

.PHONY: all install clean run debug release help
