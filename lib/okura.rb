# coding: utf-8
require 'csv'

def todo
  $stderr.puts "TODO at #{caller[1]}"
end


module Okura
  class Tagger
    todo
    def initialize dic,mat
      @dic,@mat=dic,mat
    end
    attr_reader :dic
    attr_reader :mat
    # -> [String]
    def wakati str
      mincost_path=parse(str).mincost_path
      return nil if mincost_path.nil?
      return mincost_path.map{|node|node.word.surface}
    end
    # -> Nodes
    def parse str
      chars=str.split(//)
      nodes=Nodes.new(chars.length+2)
      nodes.add(0,Node.mk_bos)
      nodes.add(chars.length+1,Node.mk_eos)
      str.length.times{|i|
        @dic.possible_words(str,i).each{|w|
          nodes.add(i+1,Node.new(w))
        }
      }
      nodes
    end
  end
  class Nodes
    def initialize len
      @begins=(0...len).map{[]}
      @ends=(0...len).map{[]}
    end
    def [](i)
      @begins[i]
    end
    # -> [Node] | nil
    def mincost_path
      todo
    end
    def add i,node
      @begins[i].push node
    end
  end
  class Node
    def initialize word
      @word=word
      @nearest_prev=nil
      @total_cost=nil
    end
    attr_reader :word
    attr_accessor :nearest_prev
    attr_accessor :total_cost
    def to_s
      "Node(#{word},#{total_cost})"
    end
    def self.mk_bos
      node=Node.new Word.new('BOS',0,0,0)
      node.total_cost=0
      node
    end
    def self.mk_eos
      Node.new Word.new('EOS',0,0,0)
    end
  end
  class Word
    def initialize surface,lid,rid,cost
      @surface,@lid,@rid,@cost=surface,lid,rid,cost
    end
    attr_reader :surface
    attr_reader :lid
    attr_reader :rid
    attr_reader :cost
    def == other
      return [surface,lid,rid,cost] ==
        [other.surface,other.lid,other.rid,other.cost]
    end
    def to_s
      "Word(#{surface},#{lid},#{rid},#{cost})"
    end
  end
  class Feature
    def initialize id,text
      @id,@text=id,text
    end
    attr_reader :id
    attr_reader :text
    def to_s
      "Feature(#{id},#{text})"
    end
  end
  class Features
    def initialize
      @map_id={}
    end
    def from_id id
      @map_id[id]
    end
    def add feature
      @map_id[feature.id]=feature
    end
    def size
      @map_id.size
    end
    def self.load_from_io io
      fs=Features.new
      io.each_line{|line|
        id_s,name=line.strip.split(/ /,2)
        id=id_s.to_i
        fs.add Feature.new(id,name)
      }
      fs
    end
  end
  class Trie
    # -> Enumerable<Word>
    def lookup str,i
      todo
    end
    class Builder
      # Word -> ()
      def add word
        todo
      end
      # () -> Trie
      def build
        todo
      end
    end
  end
  def CompositeDic
    def initialize dictionaries
      @dictionaries=dictionaries
    end
    # -> [Word]
    def possible_words str,i
      @dictionaries.map{|dic|dic.possible_words(str,i)}.flatten(1)
    end
  end
  class WordDic
    def initialize
      @size=0
      @root=TrieNode.new
    end
    class TrieNode
      def initialize
        @nodes={}
        @leafs=[]
      end
      def add word,i=0
        if i==word.surface.length
          @leafs.push word
        else
          fst=word.surface[0]
          node=@nodes[fst]
          @nodes[fst]=node=TrieNode.new if node.nil?
          node.add word,i+1
        end
      end
      def find_all str,i,res=Array.new
        res.concat @leafs
        return res unless i < str.length
        node=@nodes[str[i]]
        return res if node.nil?
        node.find_all(str,i+1,res)
        res
      end
    end
    attr_reader :size
    def define word
      @size+=1
      @root.add word
    end
    # -> [Word]
    def possible_words str,i
      @root.find_all str,i
    end
    # IO -> WordDic
    def self.load_from_io io
      wd=WordDic.new
      CSV.instance(io).each {|row|
        surface,lid_s,rid_s,cost_s,*rest=row
        lid,rid,cost=[lid_s,rid_s,cost_s].map(&:to_i)
        wd.define Word.new(surface,lid,rid,cost)
      }
      wd
    end
  end
  class UnkDic
    # -> [Word]
    def possible_words str,i
      todo
      []
    end
    # -> UnkDic
    def self.load_from_io io
      todo
    end
  end
  class Matrix
    def initialize mat
      @mat=mat
    end
    # Feature -> Feature -> Int
    def cost rid,lid
      @mat[rid][lid]
    end
    def set(rid,lid,cost)
      @mat[rid][lid]=cost
    end
    def rsize
      @mat.size
    end
    def lsize
      rsize==0 ? 0 : @mat.first.size
    end
    # -> Matrix
    def self.load_from_io io
      rsize,lsize=io.readline.split(/\s/).map(&:to_i)
      mat_arr=(0...rsize).map{[nil]*lsize}
      io.each_line{|line|
        rid,lid,cost=line.split(/\s/).map(&:to_i)
        mat_arr[rid][lid]=cost
      }
      Matrix.new mat_arr
    end
  end
end