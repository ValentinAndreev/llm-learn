import { application } from "controllers/application"
import ChatController from "controllers/chat_controller"

application.register("chat", ChatController)
