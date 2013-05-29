# Simple Trie implementation for word correction
#
# Usage is as following:
#
# 1. Create a new Trie instance by passing a dictionary file to the constructor.
# 2. Call `correct` to obtain a word's correction.
#
# An alternative to [http://norvig.com/spell-correct.html](http://norvig.com/spell-correct.html)
#
# * **TODO** make it shorter
# * **TODO** publish it
# * **TODO** try to come out with a mysql version, like a simple ruby gem for word correction using mysql
#
class Trie

  class Node

    attr_accessor :leafs, :count, :word

    def initialize(_word)
      @word = _word
      @leafs = Hash.new { |h,k| h[k] = Node.new @word + k }
      @count = 0
    end
  end

  def initialize(_path)
    @root = Node.new ''
    words = File.open(_path, 'rb').read.scan(/[A-Z]+/i).collect { |w| w.downcase } # file close?
    words.each do |word|
      word_node = word.split('').reduce(@root) { |r,c| r.leafs[c] }
      word_node.count += 1
    end
  end

  # Given a word, return the word that is most likely the word the user meant.
  #
  # **TODO** Improve likelihood function
  #
  def correct(_word, _max_error=2)
    results = []
    candidates(results, _word, @root, _max_error)
    results.reduce(nil) { |t,r| if t.nil? or t[:error] < r[:error] or t[:count] < r[:count] then r else t end }
  end

private

  # Search recursively for cadidate words.
  #
  # **TODO** Prune search tree in the following cases:
  #
  # * If just `inserted`, do not `delete` (same as doing nothing)
  # * If just `replaced`, do not `delete` (same as just deleting)
  # * If just `deleted`, do not `insert` (same as replacing but with more errors)
  # * If just `transposed`, do not `delete` (same as deleting after replacing)
  # * **TODO** more cases...
  #
  def candidates(_result, _word, _node, _error)

    if _word.length == 0
      _result << { word: _node.word, error: _error, count: _node.count } if _node.count > 0
      return
    end

    _node.leafs.each do |k, l|
      if _word.first == k
        candidates(_result, _word[1..-1], l, _error) # no error
      elsif _error > 0
        candidates(_result, _word, l, _error-1) # insert
        candidates(_result, _word[1..-1], l, _error-1) # replace (skip)
      end
    end

    candidates(_result, _word[1..-1], _node, _error-1) if _error > 0 # delete
    candidates(_result, _word[1]+_word[0]+_word[2..-1], _node, _error-1) if _error > 0 and _word.length > 1 # transpose
  end

end

