require 'open-uri'
require 'json'

MESSAGE_HASH = {
  1 => 'is a valid word.',
  2 => 'is not an English word.',
  3 => 'is made from letters outside of the grid.'
}

$letters = Array.new(10)

class GamesController < ApplicationController
  $result_log = []

  def initialise_dictionary_hash(attempt)
    dictionary = URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
    dictionary_hash = JSON.parse(dictionary)
    return dictionary_hash
  end

  def message_selector(grid_map_test)
    # raise
    if grid_map_test.any?(false)
      message = 3
    elsif initialise_dictionary_hash(params[:word])['found']
      message = 1
    else
      message = 2
    end
    message
  end

  def validate
    attempt_array = params[:word].downcase.chars.sort.map { |element| [element] }.sort

    grid_array = $letters.map { |letter| [letter] }.sort
    # raise
    grid_array_difference = grid_array.difference(attempt_array)
    # raise
    grid_array -= grid_array_difference
    # raise
    grid_map_test = attempt_array.map do |letter|
      boolean = grid_array.include?(letter)
      grid_array.shift
      boolean
    end
    # raise
    message_selector(grid_map_test)
  end

  def new
    $letters.map! { ('a'..'z').to_a[rand(26)] }
    $start_time = Time.now
  end

  def score
    # raise
    validation_message = validate
    score = 0
    score = ((params[:word].length / (Time.now - $start_time)) * 100).floor if validation_message == 1
    @result = {
      time: (Time.now - $start_time),
      score: score,
      past_word: params[:word],
      message: MESSAGE_HASH[validation_message]
    }
    # raise
    $result_log.push(@result)
  end
end
# Need two parts to #score -- the actual score part and the validation of answer part
