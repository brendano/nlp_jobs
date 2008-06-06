require 'xmas'
require 'open-uri'
require 'yaml'
require 'fileutils'

class TempJob < Xmas::JSJob
  USET = "temp"
  class << self
    
    #okay, so this is the form that they'll be filling in.
    def form_json
    [
       ['*hypothesis',['XXX', 'YYY', ' Neither or Unknown']],
       ['comment', '']]
    #*hypothesis, ['Before', 'After', 'Neither or Unknown']
    #<%= @option1 %>', '<%= option2 %>', 'Neither or Unknown']],
    end
     
    def form_labels
      { :hypothesis => {:required => true, :label => "Which came first?"}}
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
      <h2>Order News Events</h2>
      
      Below is a news report with certain words colored. Your task is to
      decide if the events that the colored words describe happened before
      or after each other.  The article is describing real world events, so
      you must decide how the events happened in the real world.  Many
      events overlap in time or are ambiguous.  In those cases, mark
      "unknown" as your answer.
<p>
      For example, in the following two sentences, "<font color="red">pushed</font>" happened before "<font color="blue">fell</font>", even though "fell" might occur before "pushed" in the actual
      text ordering:
<p>
      John <font color="blue">fell</font>. Sam <font color="red">pushed</font> him.
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
      <div style="float:left;width:700px">
          <h3>In the following article, which event happens first:
          <span class="opt1">
              <%= @w1 %>
              </span> or 
          <span class="opt2">
              <%= @w2 %>
          </span>?</h3>
          <p>
          <div><h3>Article</h3><p><%= @article %></p>
          </div>
      <hr>
      </div>      
      TABLE
    end
    
    def js
      <<-JS
        window.addEvent('load', function(){
          $$('.wrapper').each(function(elt) {
                var opt1 = elt.getElement('.opt1')
                if (opt1 == null) return
                var text1 = opt1.innerHTML.replace(/^\s+|\s+$/,'')
                
                var opt2 = elt.getElement('.opt2')
                if (opt2 == null) return
                var text2 = opt2.innerHTML.replace(/^\s+|\s+$/,'')              
                
                var lab1 = elt.getElement('fieldset')      
                var rest = lab1.innerHTML.replace(/XXX\</,text1 + "<")
                rest = rest.replace(/YYY\</,text2 + "<")
               
                elt.getElement('fieldset').innerHTML = rest    
            })
          })
        JS
    end
    
    #if(lab.innerHTML.contains('XXX'))
    #{
    

#    $$('input.none').each(function(i){
#      i.addEvent('click', function(){
#        var id = this.getParent('div').getParent().get('id')
#        var awesome = eval(id)
#        if(this.checked)
#           awesome.stopValidation()
#        else
#           awesome.addValidation()
#      })
#    })
    
    #  $$('.wrapper').each(function(elt) {
    #      var hyp = elt.getElement('.label')
    #      if (hyp == null) return
    #      var text = hyp.value.replace(/Before/,'')
    #      elt.getElement('label').value = text
    
    def units_per_hit
      10
    end
    
    def title
      "Order News Events"
    end
    
    def description
      "Before or after?"
    end
    
    def judgements_per_unit
      3
    end
    
    def reward_cents
      3
    end
    
    def keywords
      "temporal, event"
    end
    
  end
end