skip = true


dependency "efs" {

  config_path = "..//efs"
  
  mock_outputs = {

    security_group_id = "sg-00000001"
    
  }
}