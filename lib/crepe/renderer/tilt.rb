require 'tilt'

module Crepe
  module Renderer
    # Sends a resource and template to [Tilt][] for rendering, falling back
    # to {Renderer::Simple} if no template name is provided (or can be
    # derived). Template names are derived by the resource class's ability to
    # return a {.model_name}.
    #
    # [Tilt]: https://github.com/rtomayko/tilt
    class Tilt < Base

      # Raised when a template name is derived but cannot be found in the
      # template path.
      class MissingTemplate < RenderError
      end

      include Pagination

      class << self

        def configure
          yield self
        end

        def template_path
          @template_path ||= 'app/views'
        end

        def layout_path
          @layout_path ||= template_path
        end

        attr_writer :template_path, :layout_path

      end

      def render resource, options = {}
        resource      = super

        formats       = options.fetch :formats,  [endpoint.format]
        handlers      = options.fetch :handlers, [:*]
        path_options  = { formats: formats, handlers: handlers }

        template_name = options.fetch :template, model_name(resource)
        template = find_template template_name, path_options if template_name

        unless template
          return Simple.new(endpoint).render resource, options
        end

        locals = {
          template_name => resource, resource: resource, links: links.to_h
        }
        if layout_name = options[:layout]
          layout = find_template layout_name, path_options.merge(layout: true)
          layout.render { template.render endpoint, locals }
        else
          template.render endpoint, locals
        end
      end

      private

        def model_name resource
          if resource.respond_to? :model_name
            resource.model_name.collection
          elsif resource.class.respond_to? :model_name
            resource.class.model_name.singular
          else
            resource.class.name
          end
        end

        def find_template name, options
          query = template_path name, options.delete(:layout)

          formats, handlers = options.values
          query << '{.{%{formats}},}.{%{handlers}}' % {
            formats: formats.join(','), handlers: handlers.join(',')
          }

          template_path = Dir[query].reject { |path|
            ext = File.basename(path).split('.').last
            File.directory?(path) || ::Tilt.mappings[ext].nil?
          }.first

          ::Tilt.new template_path if template_path
        end

        def template_path name, layout = false
          base = layout ? self.class.layout_path : self.class.template_path
          File.join base, name
        end

    end
  end
end
