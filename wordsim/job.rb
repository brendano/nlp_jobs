require 'rubygems'
require 'xmas'

class WordSim < Xmas::JSJob
  USET = nil   #"wordsim"

  class << self
    
    def form_json
      [
        ["sim", ""]
      ]
    end
    
    def form_labels
      {'sim' => {
        :label => "Similarity (0-10)",
        :required => true,
        :validation => ["^(\\d|10)(\\.\\d+|)$", ["Please use numbers from 0 through 10.  Decimals are OK."]]        
        }
      }
    end
    
    def instructions
      %{
      <h1>Word pair similarity</h1>

      <p>Below is a list of pairs of words. For each pair, please assign
      a numerical similarity score between 0 and 10 (0 = words are totally
      unrelated, 10 = words are VERY closely related). By definition,
      the similarity of the word to itself should be 10. You may assign
      fractional scores (for example, 7.5).</p>
            
      }
    end
    
    def styles
      %{
        .problem { font-size: 16pt }
      }
    end
    
    def problem
      %{
        <div class="problem">
          <%= @word1 %> &nbsp; <%= @word2 %>
        </div>
      }
    end

    def title
      "Word similarity: 20 word pairs"
    end

    def description
      "Decide how similar words are."
    end
    
    def units_per_hit
      20
    end
    def judgements_per_unit
      10
    end
    def reward_cents
      2
    end
    def keywords
      ""
    end

  end
  
  
end