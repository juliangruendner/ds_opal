config_orig = open('ds_data/opal/data/opal-config.xml', 'r')
to_insert = open('ds_base_config.xml', 'r')

orig_data = config_orig.read()
config_orig.close()

new_config= open('ds_data/opal/data/opal-config.xml', 'w')
insert_data = to_insert.read()

begin_replace = orig_data.find('<org.obiba.opal.datashield.cfg.DatashieldConfiguration>')
end_replace = orig_data.find('</org.obiba.opal.datashield.cfg.DatashieldConfiguration>') 
end_replace += len('</org.obiba.opal.datashield.cfg.DatashieldConfiguration>')

new_config.write(orig_data[:begin_replace])
new_config.write(insert_data)
new_config.write(orig_data[end_replace:])