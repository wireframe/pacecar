module Pacecar
  module State
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def has_state(*names)
        opts = names.extract_options!
        names.each do |name|
          constant = opts[:with] || const_get(name.to_s.pluralize.upcase)
          constant.each do |state|
            scope "#{name}_#{state.downcase}".to_sym, :conditions => ["#{quoted_table_name}.#{connection.quote_column_name name} = ?", state]
            scope "#{name}_not_#{state.downcase}".to_sym, :conditions => ["#{quoted_table_name}.#{connection.quote_column_name name} <> ?", state]
            self.class_eval %Q{
              def #{name}_#{state.downcase}?
                #{name} == '#{state}'
              end
              def #{name}_not_#{state.downcase}?
                #{name} != '#{state}'
              end
            }
          end
          scope "#{name}".to_sym, lambda { |state|
            { :conditions => ["#{quoted_table_name}.#{connection.quote_column_name name} = ?", state] }
          }
          scope "#{name}_not".to_sym, lambda { |state|
            { :conditions => ["#{quoted_table_name}.#{connection.quote_column_name name} <> ?", state] }
          }
        end
      end

    end
  end
end
