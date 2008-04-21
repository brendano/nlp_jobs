require 'rubygems'
require 'xmas'

class MetoCountryJob < Xmas::JSJob
  USET = "meto_country"

  CATEGORIES = [
    ["literal", '<b>Literal:</b> "(in) the geographical region known as X" (~80% of all examples)',
      "I visited Italy on vacation." ],
    ["person", %{<b>Person</b>: "people / group / organization associated with / inhabiting / frequenting / representing X" (~15% of all examples)}, %{Italy scored two goals in the World Cup game.}],
    ["event", %{<b>Event</b>: "event that takes/took place in X" / "situation in X" / "action in/directed towards X" (<1% of all examples)},  %{He was a veteran of Vietnam}],
    ["product", %{<b>Product</b>: "(the) product that was/were produced in X"(<1% of all examples)}, %{I bought a real Meissen}],
    ["name", %{<b>Name</b>: "(by) the name X" (<1% of all examples)}, %{Italy has three syllables.}],
    ["representation", %{<b>Representation</b>: "representation (photo, painting, drawing, etc.) of X" (<1% of all examples)}, %{Italy looks like a boot on the map.}],
    ["gt1", %{<b>Ambiguous</b>: More than one interpretation due to multiple contexts with different constraints on the reading. (~2% of all examples)}, nil],
    ["none", %{<b>None of the above</b>  (<1% of all examples)}, nil],
  ].map{|cat,descr,ex| [cat,  descr.gsub(/(\([^)]*\))$/, "<span class='prior'>\\1</span>"),  ex ]}
  
  CATEGORY_MORE_EXAMPLES = {
    "literal" => [
      "I visited <b>Italy</b> on vacation.",
      "The successive rebellions against Soviet-backed regimes -- <b>East Germany</b> in 1953, in Poland and Hungary in 1956, in Czechoslovakia in 1968 and in Poland in the early 1980s -- progressively undermined the allegiance of foreign radicals to the USSR.",
      "His long career in <b>France</b> which led him to hold high military and administrative posts."
    ]
  }

  class << self
    
    def form_json
      [
        ['*category', 
          CATEGORIES.map do |label,text,ex|
            s = "#{text}"
            if ex
              s << "<br /><div class='example'>Example: <span class='inner'>\"#{ex}\"</span></div>"
              end
            s << "|#{label}"
            s
          end
        ]
      ]      
    end
    
    def form_labels
      {'category' => "Please choose the interpretation of the bolded country that best suits the sentence:"
      }
    end
    
    def instructions
      %{
      <h1>Name word identification</h1>
<p>In this task you will be presented with a series of paragraphs.  In each paragraph there will be a single bolded term that is the name of a country.  Your task is to distinguish whether the country is being used literally, to refer to the actual geographical or political entity, or figuratively, to refer to, for example, a sports team or an event.  If the country is being used figuratively, please mark what kind of entity the country is actually being used in place of -- a person or group of people, and event, a product, or so forth.  In general we've observed that nearly all country usages are either literal, or figuratively as a person or group of people;  in each of the check boxes below we've given the estimated percentages of each type.</p>

<p>Here are a few sample sentences to help you understand the different types of figurative usage, along with the observed percentages of different usage types:</p>

<ul>
    } + CATEGORIES.map { |cat, smalltext|
      "<li>#{smalltext}" +
      "<br />Examples: <ul>" +
      (CATEGORY_MORE_EXAMPLES[cat] || []).map { |ex|
        "<li>#{ex}"
      }.join + "</ul>"
    }.join + %{
</ul>
    }
    end
    
    def styles
      <<-EOF
        div.text { font-size: 15pt }
        div.text b { font-size: 16pt; color: darkblue; font-style:italic }
        
        div.example { margin-left: 30pt; }
        div.example .inner { color: #355; font-style:italic }
        .prior { color: #355; margin-left: 5pt  }
      EOF
    end

    def bla(x)
    end
    
    def problem
      s = <<-EOF
        <div class="text"><%= @text %></div>
      EOF
    end

    def title
      "Wikipedia comments and articles"
    end

    def description
      "Decide if a Wikipedia comment is about a particular sentence in the Wikipedia article."
    end
    
    def units_per_hit
      15
    end
    def judgements_per_unit
      4
    end
    def reward_cents
      1
    end
    def keywords
      ""
    end

  end
  
  
end