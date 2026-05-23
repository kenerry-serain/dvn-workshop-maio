variable "default_tags"{
    type = map(string)
    default = {
        Project = "workshop-devops-na-nuvem-ia"
        Environment = "production"
    }
}