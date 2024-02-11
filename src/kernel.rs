const VGA_WIDTH: usize = 80;
const VGA_HEIGHT: usize = 25;

#[repr(u8)]
#[derive(Clone, Copy)]
enum Color {
    Black = 0,
    Blue = 1,
    Green = 2,
    Red = 4,
    Yellow = 14,
    White = 15,
}

#[derive(Clone, Copy)]
struct VgaChar {
    ascii_character: u8,
    color_code: Color,
}

impl VgaChar {
    fn new(ascii_character: u8, color_code: Color) -> Self {
        Self {
            ascii_character,
            color_code,
        }
    }
}

struct Terminal {
    buffer: [[VgaChar; VGA_WIDTH]; VGA_HEIGHT],
    cursor_row: usize,
    cursor_col: usize,
}

impl Terminal {
    fn new() -> Self {
        let default_char = VgaChar::new(b' ', Color::White);
        let buffer = [[default_char; VGA_WIDTH]; VGA_HEIGHT];
        Self {
            buffer,
            cursor_row: 0,
            cursor_col: 0,
        }
    }

    fn write_char(&mut self, c: char, color: Color) {
        match c {
            '\n' => {
                self.cursor_row += 1;
                self.cursor_col = 0;
            }
            _ => {
                if self.cursor_col >= VGA_WIDTH {
                    self.cursor_col = 0;
                    self.cursor_row += 1;
                }
                if self.cursor_row >= VGA_HEIGHT {
                    // Scroll here if needed
                }
                self.buffer[self.cursor_row][self.cursor_col] = VgaChar::new(c as u8, color);
                self.cursor_col += 1;
            }
        }
    }

    fn initialize(&mut self) {
        for row in 0..VGA_HEIGHT {
            for col in 0..VGA_WIDTH {
                self.buffer[row][col] = VgaChar::new(b' ', Color::Black);
            }
        }
    }

    fn print(&mut self, s: &str) {
        for c in s.chars() {
            self.write_char(c, Color::White);
        }
    }
}

#[no_mangle]
pub extern "C" fn kernel_main() {
    let mut terminal = Terminal::new();
    terminal.initialize();
    terminal.print("Hello, World!");
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
