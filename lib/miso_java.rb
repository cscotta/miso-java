module MisoJava
  
  BASE = File.dirname(__FILE__) + '/..'
  TEMPLATES = "#{BASE}/template/templates"
  
  class << self

    def load_template(path)
      return load_file("#{TEMPLATES}/#{path}")
    end

    def load_file(path)
      contents = ""
      file = File.new(path, "r")
      while (line = file.gets)
        contents += line
      end
      file.close
      return contents
    end
    
    def generate(template, model, columns)
      
      # Application Name
      appname = Dir.pwd.split('/').last
      template.gsub!('[[APPNAME]]', appname.downcase)      
      
      # Model Name
      template.gsub!('[[ModelNameLowercase]]', model.downcase)
      template.gsub!('[[ModelNameCapitalized]]', model.capitalize)

      # Model Definition
      getter_and_setter_definition = ""
      columns.each do |column|
        getter_and_setter_definition += "public String get#{column.capitalize}();\n  "
        getter_and_setter_definition += "public void set#{column.capitalize}(String #{column});\n  "
      end
      template.gsub!('[[GetterAndSetterDefinition]]', getter_and_setter_definition)


      # Model Access
      json_output_for_columns = ""
      columns.each do |column|
        json_output_for_columns += "json.put(\"#{column}\", #{model.downcase}.get#{column.capitalize}());\n    "
      end
      template.gsub!('[[JSONOutputForColumns]]', json_output_for_columns)

      setters_from_params = ""
      columns.each do |column|
        setters_from_params += "#{model.downcase}.set#{column.capitalize}(params.get(\"#{column}\").toString());\n    "
      end
      template.gsub!('[[SetterFromParamsImplementation]]', setters_from_params)

      # New Template
      fields_for_new_model = ""
      columns.each do |column|
        fields_for_new_model += "<label for=\"#{column}\">#{column.capitalize}: </label><input name=\"#{column}\" class=\"text\" type=\"text\" /><br />\n    "
      end
      template.gsub!('[[InputFieldsForNewModel]]', fields_for_new_model)


      # Edit Template
      fields_for_edit_model = ""
      columns.each do |column|
        fields_for_edit_model += "<label for=\"#{column}\">#{column.capitalize}: </label><input name=\"#{column}\" class=\"text\" type=\"text\" value=\"<%= #{model.downcase}.get#{column.capitalize}() %>\" /><br />\n    "
      end
      template.gsub!('[[InputFieldsForEditModel]]', fields_for_edit_model)

      # Index Template
      index_table_headings = ""
      columns.each do |column|
        index_table_headings += "<th>#{column.capitalize}</th>\n    "
      end
      template.gsub!('[[TableHeadingsForIndexColumnNames]]', index_table_headings)

      index_td_content = ""
      columns.each do |column|
        index_td_content += "<td><%= #{model.downcase}.get#{column.capitalize}() %></td>\n    "
      end
      template.gsub!('[[TDsForIndexColumns]]', index_td_content)

      # Show Template
      show_columns = ""
      columns.each do |column|
        show_columns += "<p><strong>#{column.capitalize}:</strong> <%= #{model.downcase}.get#{column.capitalize}() %></p>\n    "
      end
      template.gsub!('[[ShowFieldsForColumns]]', show_columns)

      # SQL
      column_names = ""
      columns.each do |column|
        column_names += "`#{column}` varchar(255) DEFAULT NULL,\n"
      end
      template.gsub!('[[ColumnLinesForSQL]]', column_names)
      
      template.gsub!('[[PWD]]', Dir.pwd.split('/').last)

      return template
    end


    def create_app(args)
      puts "Creating application: #{ARGV[1]}\n\n"
      FileUtils.cp_r "#{BASE}/template/skeleton", 'miso-skeleton'
      FileUtils.mv 'miso-skeleton', ARGV[1]

      # Create web.xml
      web_xml = load_template('web.xml')
      web_xml.gsub!('[[AppName]]', ARGV[1].capitalize).gsub!('[[AppNameLowercase]]', ARGV[1].downcase)
      File.open("#{ARGV[1]}/web.xml", 'w') {|f| f.write(web_xml) }
      
      # Update DB Name
      model = load_file("#{ARGV[1]}/app/miso/Model.java")
      model.gsub!('localhost/miso', "localhost/#{ARGV[1].downcase}")
      File.open("#{ARGV[1]}/app/miso/Model.java", 'w') {|f| f.write(model) }

      # Update Header Template Paths
      header = load_file("#{ARGV[1]}/app/views/includes/header.html")
      header.gsub!('[[APPNAME]]', "#{ARGV[1].downcase}")
      File.open("#{ARGV[1]}/app/views/includes/header.html", 'w') {|f| f.write(header) }

      
      # Generate scripts
      %w(build restart start stop).each { |script| generate_script(script, ARGV[1].downcase) }
    end

    def generate_script(name, app)
      script = load_file("#{BASE}/template/templates/script/#{name}")
      script.gsub!('[[JETTY_PATH]]', "#{BASE}/jetty")
      script.gsub!('[[APPNAME]]', app)
      File.open("#{ARGV[1]}/script/#{name}", 'w') {|f| f.write(script) }
      FileUtils.chmod(0744, "#{ARGV[1]}/script/#{name}")
    end

    def scaffold(args)      
      # Check to ensure we're inside a miso project.
      @cool = File.exist?('app/Application.java')

      if not @cool
        puts "Please ensure you're in the root of a miso project before using the scaffold generator.\n\n"
        Process.exit
      end
      
      model   = ARGV[1].capitalize
      columns = ARGV[2..ARGV.size]

      # Load Templates
      puts "Creating model #{model} with columns: #{columns.join(' ')}\n"
      controller        = load_template('controllers/Controller.java')
      model_definition  = load_template('models/ModelDefinition.java')
      model_access      = load_template('models/ModelAccess.java')

      index = load_template('views/index.jsp')
      show  = load_template('views/show.jsp')
      add   = load_template('views/add.jsp')
      edit  = load_template('views/edit.jsp')
      sql   = load_template('table.sql')


      # Create directory for the views.
      File.makedirs "app/views/#{model.downcase}"

      puts "Generating Controller..."
      File.open("app/controllers/#{model.capitalize}Controller.java", 'w') {|f| f.write(generate(controller, model, columns)) }

      puts "Generating Model Definition..."
      File.open("app/models/#{model.capitalize}.java", 'w') {|f| f.write(generate(model_definition, model, columns)) }

      puts "Generating Model Access Layer..."
      File.open("app/models/#{model.capitalize}Model.java", 'w') {|f| f.write(generate(model_access, model, columns)) }

      puts "Generating Index Template..."
      File.open("app/views/#{model.downcase}/index.jsp", 'w') {|f| f.write(generate(index, model, columns)) }

      puts "Generating Show Template..."
      File.open("app/views/#{model.downcase}/show.jsp", 'w') {|f| f.write(generate(show, model, columns)) }

      puts "Generating Add Template..."
      File.open("app/views/#{model.downcase}/add.jsp", 'w') {|f| f.write(generate(add, model, columns)) }

      puts "Generating Edit Template..."
      File.open("app/views/#{model.downcase}/edit.jsp", 'w') {|f| f.write(generate(edit, model, columns)) }

      puts "Generating SQL...\n\n"
      puts "Please execute the following SQL before starting the app:\n\n"
      sql = generate(sql, model, columns)
      File.open("db/schema/create_#{model.downcase}.sql", 'w') {|f| f.write(sql) }
      puts sql + "\n\n"

      puts "Registering Controller in Application.java..."
      app = load_file("app/Application.java")
      app.gsub!("// Import Controllers (Don't remove this line)", "// Import Controllers (Don't remove this line)\nimport controllers.#{model.capitalize}Controller;")
      File.open("app/Application.java", 'w') {|f| f.write(app) }
      puts "\nDone!\n\n"
    end

  end # class << self
end # MisoJava