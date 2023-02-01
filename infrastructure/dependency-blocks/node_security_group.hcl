skip = true


dependency "node_security_group" {

  config_path = "..//node_security_group"

  mock_outputs = {

    security_group_id = "sg-00000000"
    
  }
}