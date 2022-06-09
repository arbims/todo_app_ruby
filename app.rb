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

  def toggle(tab)
		tab == 'TODO' ? 'DONE' : 'TODO'
	end

  def list_up(lists, list_curr)
		if list_curr and list_curr > 0
			list_curr = list_curr - 1
		else
			list_curr = 0
		end 
	end

  def list_down(lists, list_curr)
		if list_curr and list_curr < lists.length
			list_curr = list_curr + 1 
		else
			list_curr = lists.length
		end
	end

end

begin

  quit = false 
  insert_mode = false
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
  curr_done = 0
  tab = "TODO"
  height = Curses.lines
  width = Curses.cols
  
  todowin = Curses::Window.new(height - 2, (width / 2)  , 0, 0)
  todowin.box()
  donewin = Curses::Window.new(height - 2, (width / 2) , 0, (width / 2) )
  donewin.box()

  newtodo = Curses::Window.new(5 - 1, width  , 0, 0)
  newtodo.box()
  str = ''
  while !quit
    
    todowin.clear
    todowin.resize(Curses.lines - 3, Curses.cols / 2)
    todowin.move(0, 0)
    todowin.box()
    
    donewin.clear
    donewin.resize(Curses.lines - 3, Curses.cols / 2)
    donewin.move(0, Curses.cols / 2)
    donewin.box()

    newtodo.clear
    newtodo.resize(Curses.lines - 5,0)
    newtodo.move(Curses.lines - 5, 0)
    newtodo.box()
    
    ui.label(0, 2  , "NEW TODO", REGULAR_PAIR, newtodo)
    begin_loop = 1
    ui.label(0, (width / 4)  , "TODO [ ]", REGULAR_PAIR, todowin)
    
    todos.each_with_index do |todo, index|
      if index == curr_todo and tab == 'TODO'
        pair = HIGHLIGHT_PAIR
      else
        pair = REGULAR_PAIR
      end
      #puts todo.completed
        text = "[ ] #{todo.text}"
        ui.label(index + begin_loop, 0 + 1, text,pair, todowin)
    end

    ui.label(0, (width / 4)  , "DONE [x]", REGULAR_PAIR, donewin)
    dones.each_with_index do |done, index|
      if index == curr_done and tab == 'DONE'
        pair = HIGHLIGHT_PAIR
      else
        pair = REGULAR_PAIR
      end
      #puts todo.completed
        text = "[x] #{done.text}"
        ui.label(index + begin_loop , 0 + 1, text,pair, donewin)
    end
    
    bottombar = "`q` to quit."
    
    bottombar = bottombar + "\t\tw: #{width} h: #{height} lastchar: #{inputchar} todos.length: #{todos.length} curr_todo: #{curr_todo} dones.length: #{dones.length} curr_done: #{curr_done}"
    y = height - 1
    empty_str = " " * width
    
    ui.label_not_win(y , 0, "#{empty_str}", HIGHLIGHT_PAIR)
    ui.label_not_win(y, 0, bottombar, HIGHLIGHT_PAIR)
    refresh
    todowin.refresh
    donewin.refresh
    newtodo.refresh
    
    if insert_mode == false
      inputchar = todowin.getch
      case inputchar
      when 'q'
        quit = true
      when 'A'
        case tab
  			when 'TODO'
  				curr_todo = ui.list_up(todos, curr_todo)
  			when 'DONE'
  				curr_done = ui.list_up(dones, curr_done)
  			end
      when 'B'
        case tab
  			when 'TODO'
  				curr_todo = ui.list_down(todos, curr_todo)
  			when 'DONE'
  				curr_done = ui.list_down(dones, curr_done)
  			end
      when 'n'
        insert_mode = true
        str = ''
      when 's'
        ui.remove_element()
      when 9
  			tab = ui.toggle(tab)
      when 10
        case tab
        when 'TODO'
          if todos.length > 0
            todos[curr_todo].completed = !todos[curr_todo].completed
            dones.push(todos[curr_todo])
            todos.delete(todos[curr_todo])
            if todos.length == curr_todo
              curr_todo = curr_todo -1
            end
            if curr_todo == -1 and todos.length == 0
              tab = 'DONE'
              curr_done = 0
            end
          end
        when 'DONE'
          if dones.length > 0
            dones[curr_done].completed = !dones[curr_done].completed
            todos.push(dones[curr_done])
            dones.delete(dones[curr_done])
            if dones.length == curr_done
              curr_done = curr_done - 1
            end
            if curr_done == -1 and dones.length == 0
              tab = 'TODO'
              curr_todo = 0
            end
          end
        end
      end
    else
      ui.label(1 , 1, str ,REGULAR_PAIR, newtodo)     
      inputchar = newtodo.getch
      if (inputchar == 10) 
        todo = Todo.new(false, str)
        todos.push(todo)
        insert_mode = false
      else
        str = str + inputchar.to_s        
      end
      
      newtodo.refresh
    end

  end
  todowin.close
  donewin.close
  newtodo.close

ensure
  close_screen
end

