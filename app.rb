require 'curses'
require './Todo'
include Curses

Curses.init_screen
Curses.start_color
Curses.noecho
Curses.curs_set(0)
REGULAR_PAIR = 1
HIGHLIGHT_PAIR = 2
Curses.init_pair(REGULAR_PAIR, COLOR_WHITE, COLOR_BLACK)
Curses.init_pair(HIGHLIGHT_PAIR, COLOR_BLACK, COLOR_WHITE)

class Ui

  def label(row, col,label, pair, win)
    win.attron(color_pair(pair)| A_BLINK)
    win.setpos(row, col)
    win.addstr(label)
    win.attroff(color_pair(pair))
  end
  def label_not_win(row, col,label, pair)
    attron(color_pair(pair)| A_BLINK)
    setpos(row, col)
    addstr(label)
    attroff(color_pair(pair))
  end
end

begin

  quit = false 
  ui = Ui.new()
  inputchar = ''
  todos = [
    Todo.new(false, "app php"),
    Todo.new(false, "app C"),
    Todo.new(false, "app ruby"),
  ]
  dones = [
    Todo.new(true, "app php"),
    Todo.new(true, "app C"),
    Todo.new(true, "app ruby"),
  ]
  curr_todo = 0
  height = Curses.lines
  width = Curses.cols
  
  todowin = Curses::Window.new(height - 1, (width / 2)  , 0, 0)
  todowin.box()
  donewin = Curses::Window.new(height - 1, (width / 2) , 0, (width / 2) )
  donewin.box()

  while !quit
    
    todowin.clear
    todowin.resize(Curses.lines - 1, Curses.cols / 2)
    todowin.move(0, 0)
    todowin.box()
    donewin.clear
    donewin.resize(Curses.lines - 1, Curses.cols / 2)
    donewin.move(0, Curses.cols / 2)
    donewin.box()
    begin_loop = 1
    ui.label(0, (width / 4) - 8 , "TODO [ ]", REGULAR_PAIR, todowin)
    todos.each_with_index do |todo, index|
      if index == curr_todo
        pair = HIGHLIGHT_PAIR
      else
        pair = REGULAR_PAIR
      end
      #puts todo.completed
      if (todo.completed == false)
        text = "[ ] #{todo.text}"
        ui.label(index + begin_loop, 0 + 1, text,pair, todowin)
      else
        text = "[x] #{todo.text}"
        ui.label(index + begin_loop, 0 + 1, text,pair, donewin)
      end
    end

    ui.label(0, (width / 4) - 8 , "DONE [x]", REGULAR_PAIR, donewin)
    dones.each_with_index do |todo, index|
      if index == curr_todo
        pair = HIGHLIGHT_PAIR
      else
        pair = REGULAR_PAIR
      end
      #puts todo.completed
      if (todo.completed == false)
        text = "[ ] #{todo.text}"
        ui.label(index + begin_loop, 0 + 1, text,pair, todowin)
      else
        text = "[x] #{todo.text}"
        ui.label(index + begin_loop , 0 + 1, text,pair, donewin)
      end
    end
    
    bottombar = "`q` to quit."
    
    bottombar = bottombar + "\t\tw: #{width} h: #{height} lastchar: #{inputchar}"
    y = height - 1
    empty_str = " " * width
    
    ui.label_not_win(y , 0, "#{empty_str}", HIGHLIGHT_PAIR)
    ui.label_not_win(y, 0, bottombar, HIGHLIGHT_PAIR)
    refresh
    todowin.refresh
    donewin.refresh
    
    inputchar = todowin.getch
    case inputchar
    when 'q'
      quit = true
    when 'A'
      curr_todo = curr_todo - 1 if curr_todo > 0
    when 'B'
      curr_todo = curr_todo + 1 if curr_todo < todos.length - 1 
    when 10
      todos[curr_todo].completed = !todos[curr_todo].completed
    end

  end
  refresh
  todowin.close
  donewin.close

ensure
  close_screen
end

