require 'xmas'
require 'open-uri'
require 'yaml'
require 'fileutils'

class AffEmotionJob < Xmas::JSJob
  USET = "affemotion"
  
  class << self
    #okay, so this is the form that they'll be filling in.
    def form_json
      [
       ['anger', ''],
       ['disgust', ''],
       ['fear', ''],
       ['joy', ''],
       ['sadness', ''],
       ['surprise', ''],
       ['valence', ''],
       ['comment', '']]

    end
     
    def form_labels
      { 
        :anger => 
        {
          :required => true, 
          :label => "Anger (0-100)",
          :validation => ["^((\\d)|(\\d\\d)|(100))$", ["Please enter a number from 0 through 100."]]        
        },
        
        :disgust => 
        {
          :required => true, 
          :label => "Disgust (0-100)",
          :validation => ["^((\\d)|(\\d\\d)|(100))$", ["Please enter a number from 0 through 100."]]        
        },
        :fear => 
        {
          :required => true, 
          :label => "Fear (0-100)",
          :validation => ["^((\\d)|(\\d\\d)|(100))$", ["Please enter a number from 0 through 100."]]        
        },
        :joy => 
        {
          :required => true, 
          :label => "Joy (0-100)",
          :validation => ["^((\\d)|(\\d\\d)|(100))$", ["Please enter a number from 0 through 100."]]        
        },
        :sadness => 
        {
          :required => true, 
          :label => "Sadness (0-100)",
          :validation => ["^((\\d)|(\\d\\d)|(100))$", ["Please enter a number from 0 through 100."]]        
        },
        
        :surprise => 
        {
          :required => true, 
          :label => "Surprise (0-100)",
          :validation => ["^((\\d)|(\\d\\d)|(100))$", ["Please enter a number from 0 through 100."]]        
        },
        :valence => 
        {
          :required => true, 
          :label => "In general, how positive or negative is this headline, on a scale of:<br>-100 (very negative) <--- 0 (neutral) ---> 100 (very positive)",
          :validation => ["^-?((\\d)|(\\d\\d)|(100))$", ["Please enter a number from -100 through 100."]]        
        }
      }    
    end
=begin    
    def questions
      problem = "Product name: \"<%= unit.data['Product_Name'] %>\"<br/>
                 Brand name: \"<%= unit.data['Brand_Name'] %>\"<br/>
                 Part number: \"<%= unit.data['Part_#'] %>\"<br/>
      Try <a href='http://google.com/search?q=<%= CGI.escape(unit.data['Product_Name']+' '+unit.data['Brand_Name'])  %>' target='_blank'>searching</a> google.
      "
      #hidden_field_names = ["event_id"]

      instructions = "Given the Product name, Brand name, and potentially a Part number for a spa, search the web and complete the form below with as many attributes as possible.  If you can't fill out every field, that is okay.  If you can't find the product at all, check the \"Unable to find?\" box (<i>If other turkers are able to find the product and provide accurate data, you will not be credited for the hit</i>).  The manufacturers website is usually a good source of information, but often times information will have to be gathered from other sources."

      Xmas::JSAwesomeQuestionGenerator.new(form, problem, {:styles => styles, :legend => legend, :instructions => instructions})
    end
=end
    def instructions
    <<-YO
      <p>For each task you will be presented with a news headline.  Your task is to score each headline for how much it 
      provokes six specific emotions: anger, disgust, fear, joy, sadness, and surprise.  Each of these are to be judged on a scale of 0-100, 
      with 0 meaning "not at all", and 100 meaning "maximum emotion". Finally, please give a score on generally how emotionally negative or 
      positive the headline is, on a scale of -100 (indicating very negative) to 100 (indicating very positive), 
      with 0 meaning emotionally neutral.  Thanks!</p>
    YO
    end
    
    def problem
      <<-TABLE
      Headline: <b>\<%= @headline %></b><br/><p>
      How much does this headline evoke the following emotions?
      TABLE
    end
    
    def js
      <<-JS
        window.addEvent('load', function(){
          $$('input.none').each(function(i){
            i.addEvent('click', function(){
              var id = this.getParent('div').getParent().get('id')
              var awesome = eval(id)
              if(this.checked)
                 awesome.stopValidation()
              else
                 awesome.addValidation()
            })
          })
        })
      JS
    end
    
    def units_per_hit
      50
    end
    
    def title
      "Emotion rating for headlines"
    end
    
    def description
      "Please determine how strongly this headline evokes the following emotions:"
    end
    
    def judgements_per_unit
      10
    end
    
    def reward_cents
      5
    end
    
    def keywords
      "emotion, sentiment, headlines, anger, disgust, fear, joy, sadness, surprise, valence"
    end
  end
end