require 'xmas'
require 'open-uri'
require 'yaml'
require 'fileutils'

class RteJob < Xmas::JSJob
  USET = "rte"
  
  class << self
    #okay, so this is the form that they'll be filling in.
    def form_json
      [
       ['*hypothesis', ['Yes', 'No']],
       ['comment', '']]

    end
     
    def form_labels
      { :hypothesis => {:required => true, :label => "Can all of the information in the <b>Hypothesis</b> be inferred from the <b>Text</b>?"}}
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
      <p>
      Please state whether the second sentence (the <b>Hypothesis</b>) 
      is implied by the information in first sentence (the <b>Text</b>), 
      i.e., please state whether the <b>Hypothesis</b> can be determined to be true given
      that the <b>Text</b> is true.  Assume that you do not know anything about the situation 
      except what the <b>Text</b> itself says.  Also, note that every part of the <b>Hypothesis</b> 
      must be implied by the <b>Text</b> in order for it to be true.<p>
      <hr>
      <b>Examples:</b><p>
      <b>Text:</b><ul><li>The anti-terrorist court found two men guilty of murdering Shapour
      Bakhtiar and his secretary Sorush Katibeh, who were found with their throats cut in
      August 1991.</ul><br>
      <b>Hypothesis:</b><ul><li>Shapour Bakhtiar died in 1991.</ul><br>
      <b>Answer:</b> YES
      <hr>
      <b>Text:</b><ul><li>Many experts think that there is likely to be another terrorist attack on
      American soil within the next five years.</ul>
      <b>Hypothesis:</b><ul><li>There will be another terrorist
      attack on American soil within the next five years.</ul> 
      <b>Answer:</b> NO
      
      
      </p>
      
      <hr>
          YO
    end
    
    def styles
      %{
        ul {margin-top :0}        
      }
    end
    
    def problem
      <<-TABLE
      <b>Text:</b><ul><li><%= @text %></ul>
      <b>Hypothesis:</b><ul><li><%= @hypothesis %></ul>

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
      20
    end
    
    def title
      "Does the hypothesis follow from the text?"
    end
    
    def description
      "Please determine if the hypothesis follows from the text"
    end
    
    def judgements_per_unit
      10
    end
    
    def reward_cents
      2
    end
    
    
    def keywords
      "inference, entailment, common sense, semantics"
    end
  
  end
end