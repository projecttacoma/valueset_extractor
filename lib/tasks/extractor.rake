namespace :hqmf do
  namespace :extractor do


    desc 'Extract OIDs and QDM element types from HQMF'
    task :extract_vs_oids, [:dir] do |t, args|

      outdir = File.join('tmp','extracted_oids')
      outfile = File.join(outdir, 'extracted.csv')
      FileUtils.rm_r outdir if File.exist? outdir
      FileUtils.mkdir_p outdir

      File.open(outfile, 'a') {|f| f.write("Measure Title,CMS Id,Version,Category,Data Type,Element Title,Value Set OID,Attributes\n")}
 
      Dir.glob(File.join("#{args.dir}",'*.xml')).each do |file|

        puts "####################################"
        puts "### processing: #{file}..."
        puts "####################################"
        doc = HQMF::Parser.parse(File.open(file).read, HQMF::Parser::HQMF_VERSION_1)

        by_type = {}
        doc.all_data_criteria.each do |dc|
          key = "#{dc.code_list_id}_#{dc.definition}_#{dc.status}_#{dc.negation}"
          by_type[key] ||= {}
          elements = by_type[key]
          elements[:measure_title] ||= doc.title
          elements[:cms_id] ||= doc.cms_id
          elements[:version] ||= doc.hqmf_version_number
          elements[:definition] ||= dc.definition
          elements[:data_type] ||= dc.instance_variable_get(:@settings)['title']
          elements[:title] ||= dc.description
          elements[:code_list_id] ||= dc.code_list_id
          elements[:fields] ||= {}
          if (dc.field_values)
            dc.field_values.keys.each do |key|
              field = dc.field_values[key]
              if (field && field.type == 'CD')
                elements[:fields][key] ||= []
                elements[:fields][key] << field.code_list_id
              end
            end
          end
          if (dc.value && dc.value.type == 'CD')
            dc.value.code_list_id
            elements[:fields]['VALUE'] ||= []
            elements[:fields]['VALUE'] << dc.value.code_list_id
          end
          if(dc.negation_code_list_id)
            elements[:fields]['NEGATION'] ||= []
            elements[:fields]['NEGATION'] << dc.negation_code_list_id
          end
        end

        File.open(outfile, 'a') do |f|
          by_type.values.each do |element|
            if (element[:fields].keys.length == 0)
              output = "\"#{element[:measure_title]}\",\"#{element[:cms_id]}\",\"#{element[:version]}\",\"#{element[:definition]}\",\"#{element[:data_type]}\",\"#{element[:title]}\",\"#{element[:code_list_id]}\""
              f.write("#{output}\n")
            else
              # output = "\"#{element[:measure_title]}\",\"#{element[:cms_id]}\",\"#{element[:version]}\",\"#{element[:definition]}\",\"#{element[:data_type]}\",\"#{element[:title]}\",\"#{element[:code_list_id]}\""
              # f.write("#{output}\n")
              element[:fields].keys.each do |field_key|
                element[:fields][field_key].uniq.each do |oid|
                  output = "\"#{element[:measure_title]}\",\"#{element[:cms_id]}\",\"#{element[:version]}\",\"#{element[:definition]}\",\"#{element[:data_type]}\",\"#{element[:title]}\",\"#{element[:code_list_id]}\",\"#{field_key.titleize}\",\"#{oid}\""
                  f.write("#{output}\n")
                end
              end
            end
          end
        end

      end
    end

  end
end
