# Usage:
# ruby cleansvg.rb your-shitty-sketch-file.svg | pbcopy

require 'nokogiri'

FLOAT_RE = /[0-9.-]+/

input = ARGF.read

doc = Nokogiri::XML(input) do |config|
  config.noblanks
end

def flatten(node)
  # Recursive
  node.children.each { |child| flatten(child) }
  
  case
  when node.comment?
    node.remove
  when node.element?
    
    # Remove sketch namespace attributes
    node.attribute_nodes.each do |attr_node|
      if attr_node.namespace && attr_node.namespace.prefix == 'sketch'
        node.delete(attr_node.name)
      end      
    end
    
    # Remove the random ids
    node.delete('id')
    
    case
    when node.name == 'desc'
      node.remove
    when node.name == 'defs' && node.children.empty?
      node.remove
    when transform_empty?(node)
      splice(node)
    when translate_redundant?(node)
      translate_splice(node)
    end
  end
end

def splice(node)
  parent = node.parent
  node.children.each { |child| parent.add_child(child) }
  node.remove
  parent.children.each { |child| flatten(child) }
end

def translate_splice(node)
  x1, y1 = translate_parse(node)
  x2, y2 = translate_parse(node.parent)
  x3, y3 = (x2 + x1).round(2), (y2 + y1).round(2)
  
  node.parent['transform'] = "translate(#{ x3 },#{ y3 })"
  splice(node)
end

def transform_empty?(node)
  transform?(node) && !node['transform']
end

def translate_redundant?(node)
  translate?(node) && translate?(node.parent) && node.parent.children.length == 1
end

def translate?(node)
  transform?(node) && node['transform'] =~ /translate/
end

def transform?(node)
  node.element? && node.name == 'g'
end

def translate_parse(node)
  node['transform'].scan(FLOAT_RE).map{ |str| Float(str).round(2) }
end

flatten(doc)
puts doc
