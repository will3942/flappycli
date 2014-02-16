require 'curses'
include Curses

# Flappy CLI written in Ruby
# Released under MIT License
# Copyright Will Evans 2014

def build_bird(arr, dir, x, y)
  if x == 0 and y == 0

    row = Hash.new
    row["x"] = 24
    row["y"] = 6
    row["str"] = "/  # \\"
    arr.push(row)

    row = Hash.new
    row["x"] = 26
    row["y"] = 5
    row["str"] = "__"
    arr.push(row)

    row = Hash.new
    row["x"] = 23
    row["y"] = 7
    row["str"] = "|█|    =="
    arr.push(row)

    row = Hash.new
    row["x"] = 24
    row["y"] = 8
    row["str"] = "\\    /"
    arr.push(row)

    row = Hash.new
    row["x"] = 26
    row["y"] = 8
    row["str"] = "__"
    arr.push(row)
  else
    if dir.to_i == 1

      arr.each do |row|
        row["x"] = row["x"].to_i - x.to_i
        row["y"] = row["y"].to_i - y.to_i
      end

    else

      arr.each do |row|
        row["x"] = row["x"].to_i + x.to_i
        row["y"] = row["y"].to_i + y.to_i
      end

    end
  end
end

def gen_map(arr, term_width, term_height, refresh)

  unless refresh

    start = term_width - 20
    pipe_width = 20
    distance = 60

    while arr.count <= 500
    
      pipe = Hash.new
      pipe["x"] = start
      pipe["y"] = 2
      pipe["str"] = "#" * 20
      pipe["end"] = ((11..(term_height - 30)).to_a.sample).to_i

      arr.push(pipe)

      start += (pipe_width + distance)

    end
  else

    arr.each do |pipe|
      unless pipe["x"] <= 0
        pipe["x"] = pipe["x"] - 2
      else
        arr.delete(pipe)
      end
    end
  
  end
end

def bird_intersect(bird, pipes, term_height)

  bird.each do |row|
    for i in row["x"].to_i..(row["x"].to_i + row["str"].length.to_i) 
      pipes.each do |pipe|
        if i == pipe["x"].to_i
          if row["y"].to_i.between?(pipe["y"].to_i,pipe["end"].to_i) or row["y"].to_i.between?(pipe["end"].to_i + 11, term_height.to_i - 1)
            return true
          end
        end
      end
      if row["y"] <= 1 or row["y"] >= term_height.to_i
        return true
      end
    end
  end

  return false

end

# Init Terminal

init_screen
cbreak
noecho
stdscr.nodelay = 1
curs_set(0)

term_width = cols
term_height = lines

win = Window.new(term_height, term_width, 0, 0)

# End Init

# Init Bird

bird = Array.new

build_bird(bird, 0, 0, 0)


# End Init

# Init Pipes

pipes = Array.new

gen_map(pipes, term_width, term_height, false)

# End Init

# Init vars

last_press = 0
start = Time.now

# End Init

begin

  loop do

    # Print outside
    win.box("|", "-")

    # Print title
    win.setpos(1,3)
    win.addstr("FLAPPY CLI | Twitter: @Will3942 | Written in Ruby with Curses.")

    visible_pipes = Array.new

    pipes.each do |pipe|

      unless pipe["x"].to_i > term_width.to_i

        win.setpos(pipe["y"].to_i,pipe["x"].to_i)
        if 20 <= (term_width.to_i - pipe["x"].to_i) 
          pipe["str"] = pipe["str"]
        else
          pipe["str"] = "#" * (term_width.to_i - pipe["x"].to_i)
        end

        for i in 2..pipe["end"].to_i
          win.addstr(pipe["str"])
          win.setpos(i,pipe["x"].to_i)
        end

        for i in 0..10
          win.addstr(" " * pipe["str"].length)
          win.setpos(pipe["end"].to_i + i,pipe["x"].to_i)
        end

        for i in (pipe["end"].to_i + 11)..(term_height.to_i - 1)
          win.addstr(pipe["str"])
          win.setpos(i,pipe["x"].to_i)
        end

        visible_pipes.push(pipe)

      end

    end

    unless Curses.getch

      build_bird(bird, 0, 0, 1)

    else
      if last_press == 0
        build_bird(bird, 1, 0, 4)
        last_press = Time.now
      else
        msecs = (Time.now.to_f - last_press.to_f) * 1000.0
        last_press = Time.now
        if msecs <= 500.0
          build_bird(bird, 1, 0, 4)
        else
          build_bird(bird, 1, 0, 2)
        end
      end
    end

    bird.each do |row|

      win.setpos(row["y"].to_i,row["x"].to_i)
      win.addstr(row["str"])

    end

    if bird_intersect(bird, visible_pipes, term_height)
      
      close_screen
      
      abort("Game over! You scored #{(Time.now.to_f - start.to_f).round(1)}")
    
    else
      
      gen_map(pipes, term_width, term_height, true)

      sleep(0.1)

      win.refresh
      win.clear
    
    end

  end

ensure

  close_screen

end