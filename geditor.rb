#!/usr/bin/env ruby

=begin
* Name: geditor.rb
* Description: Simple graphic editor for Dev test
* Author: Christian Rolle
* Date: 28.03.2013
=end

class Termination < Exception
end

# TODO: automation tests, modularisation (Classes for Pixel, Canvas and Color)
# and optimisation
class Editor
  COLORS = %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
  WHITE = COLORS[14]

public
  def I x, y
    x = x.to_i
    y = y.to_i
    raise "The x coordinate must be greater than 1." if x < 1
    raise "The y coordinate must be between 1 and 250." unless y.between?(1, 250)
    clear
    (1..y).to_a.product((1..x).to_a).each do |pixel| 
      @canvas[pixel] = WHITE
    end
  end

  def C
    @canvas.keys.each do |pixel|
      @canvas[pixel] = WHITE
    end
  end

  def L x, y, color
    x = x.to_i
    y = y.to_i
    validate :color => color, :pixel => [[x, y]]
    @canvas[[x, y]] = color
  end

  def H x1, x2, y, color
    x1 = x1.to_i
    x2 = x2.to_i
    y = y.to_i
    validate :color => color, :pixel => [[x1, y], [x2, y]]
    even_line(x1, x2) do |coord|
      @canvas[[y, coord]] = color
    end
  end

  def V x, y1, y2, color
    x = x.to_i
    y1 = y1.to_i
    y2 = y2.to_i
    validate :color => color, :pixel => [[x, y1], [x, y2]]
    even_line(y1, y2) do |coord|
      @canvas[[coord, x]] = color
    end
  end

  def S
    return if @canvas.empty?
    (1..max_x).each do |x| 
      puts @canvas.select{|pixel, color| pixel.first == x}.values.join + "\n"
    end
  end

  def F x, y, color
    x = x.to_i
    y = y.to_i
    validate :color => color, :pixel => [[x, y]]
    origin_color = @canvas[[x, y]]
    color_pixel = [[x, y]]
    neighbor_pixel = []
    begin
      color_pixel.each do |pixel|
        x = pixel.first
        y = pixel.last
        [[x-1, y], [x+1, y], [x, y-1], [x, y+1]].each do |neighbor|
          if pixel_valid?(neighbor) and @canvas[neighbor] == origin_color
            neighbor_pixel << neighbor
          end
          @canvas[pixel] = color
        end
      end
      color_pixel = neighbor_pixel.uniq
      neighbor_pixel = []
    end while not color_pixel.empty?
  end
  
  def X
    @terminate = true
    raise Termination
  end

private
  def clear
    @canvas = Hash.new
    @max_pixel, @max_x, @max_y = nil
  end
  
  def even_line from, to
    if from > to
      tmp = from
      from = to
      to = tmp
    end
    (from..to).each{|coord| yield(coord)}
  end
 
  def max_pixel
    @max_pixel ||= @canvas.sort.last
  end

  def max_x
    @max_x ||= max_pixel.first.first
  end

  def max_y
    @max_y ||= max_pixel.first.last
  end

  def color_valid? color
    COLORS.include? color
  end

  def pixel_valid? pixel
    pixel.first.between?(1, max_x) and pixel.last.between?(1, max_y)
  end

  def validate params={}
    if params[:color]
      raise "Color invalid. Choose one of #{COLORS}" unless color_valid? params[:color]
    end
    if params[:pixel]
      params[:pixel].each do |pixel|
        raise "Pixel invalid. " +  
          "The X-coordinate must be a number between 1 and #{max_x} and " +
          "the Y-coordinate must be a number between 1 and #{max_y}" unless pixel_valid? pixel
      end
    end
  end
end

puts "================= Start =============================="
editor = Editor.new
termination = false
begin
  input = STDIN.gets.strip.split
  next if input.empty?
  command = input.slice!(0)
  unless editor.respond_to?(command)
    puts "Unknown command: '#{command}'." 
    next
  end
  parameters = input.reject{|parameter| parameter.nil? or parameter.empty?}
  unless Editor.instance_method(command.to_sym).arity == parameters.size
    puts "Parameters: '#{parameters}' invalid." 
    next
  end
  begin 
    editor.send(command, *parameters)
  rescue StandardError => error
    puts "Input invalid. Message: '#{error}'"
  rescue Termination
    termination = true
    puts "==== Visit my blog: http://rubyistic.blogspot.com ===="
  end
end while not termination 
puts "================= End ================================"
