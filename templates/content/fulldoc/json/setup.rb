require 'json'

# To run this: `yardoc --template-path templates --template content --format json --no-save`

def init
    # I'm honestly not sure why we need to run this, but all other setup.rb files
    # have that line. This is a prototype so 🤷‍♂️
    objects = run_verifier(options.objects)

    data = objects.map do |object|
        serialize_object(object)  
    end
    
    File.write(
        "schema.json", 
        JSON.pretty_generate(data.compact)
    )
end

def serialize_object(object)
    # This diagram is really helpful 
    # https://github.com/lsegal/yard/blob/main/docs/CodeObjects.md
    
    if object.class == YARD::CodeObjects::Proxy
        # I'm not sure if we should *always* ignore proxy objects. In the case of liquid
        # the only proxy objects come from instance mixins where they `include Enumerable`
        return nil
    end

    # This is data provided by the "Base" class
    # Every object contains at least these fields
    # There's probably a bunch of stuff in here that we don't care about
    data = {
        "type" => object.class,
        "name" => object.name,
        "namespace_type" => object.namespace&.class,
        "namespace_name" => object.namespace&.name,
        "files" => object.files,
        "source" => object.source,
        "signature" => object.signature,
        "docstring" => object.docstring,
        "dynamic" => object.dynamic,

        # This includes some "auto-generated" tags 
        # eg. `@return` on initialize methods
        "tags" => object.tags.map {|tag| serialize_tag(tag)},
    }

    # ClassObject represents... classes that have methods. Duh.
    # https://github.com/lsegal/yard/blob/main/lib/yard/code_objects/class_object.rb
    if object.class == YARD::CodeObjects::ClassObject
        # I decided to exclude children because I *think* it's very similar to method + mixins 
        # data["children"] = object.children.map {|child| serialize_object(child)}
        
        # Do we care about this?
        data["class_variables"] = object.cvars.map {|class_variable| serialize_object(class_variable)}

        # This includes methods of all visibility.
        # I don't know who decided to call this "meths"... but it was an interesting choice
        data["methods"] = object.meths.map {|method| serialize_object(method)}

        data["constants"] = object.constants.map {|constant| serialize_object(constant)} 
        
        data["instance_attributes"] = object.instance_attributes
        
        data["class_attributes"] = object.class_attributes 

        # I don't know why we would care about these two things, so I'll 
        # exclude them from the output for now
        # data["class_mixins"] = object.class_mixins.map {|mixin| serialize_object(mixin)}
        # data["instance_mixins"] = object.instance_mixins.map {|mixin| serialize_object(mixin)}
    end

    # MethodObject represents methods on classes
    # https://github.com/lsegal/yard/blob/main/lib/yard/code_objects/method_object.rb
    if object.class == YARD::CodeObjects::MethodObject
        data["visibility"] = object.visibility
        data["scope"] = object.scope
        data["explicit"] = object.explicit
        data["parameters"] = object.parameters
        data["aliases"] = object.aliases
    end

    # https://github.com/lsegal/yard/blob/main/lib/yard/code_objects/constant_object.rb
    if object.class == YARD::CodeObjects::ConstantObject
        data["value"] = object.value
    end

    return data
end
  
def serialize_tag(tag)
    # Docs: https://github.com/lsegal/yard/blob/359006641260eef1fe6d28f5c43c7c98d40f257d/docs/Tags.md
    # Class: https://github.com/lsegal/yard/blob/main/lib/yard/tags/tag.rb

    {
        "tag_name" => tag.tag_name,
        "text" => tag.text,
        "types" => tag.types,
        "name" => tag.name
    }
end