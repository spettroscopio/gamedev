﻿; Using shaders with OpenGL 2.1
; This is just the example before but modified to work with OpenGL 2.1
; The creation of the context and the shaders are slightly different.

EnableExplicit

IncludeFile "../sgl.pbi"
IncludeFile "../sgl.pb"

UseModule gl ; to get autocompletion in the IDE

Define Title$ = "Using shaders with OpenGL 2.1"

#VSYNC = 1

Procedure CallBack_Error (Source$, Desc$)
 Debug "[" + Source$ + "] " + Desc$
EndProcedure

Global gShader, gVao
 
Procedure Render (win)
 Protected w, h
 
 glClearColor_(0.1,0.1,0.25,1.0)
 glClear_(#GL_COLOR_BUFFER_BIT)
  
 sgl::GetWindowFrameBufferSize (win, @w, @h)
 
 glViewport_(0, 0, w, h)
 
 sgl::BindShaderProgram(gShader)
 
 glBindVertexArray_(gVao)    
 glDrawArrays_(#GL_TRIANGLES, 0, 3) 
    
EndProcedure

Procedure SetupShaders() 
 Protected vertex$, fragment$ 
 Protected vbo, vs, fs
 
 Protected *vertexPos = sgl::StartData()
  Data.f -0.5, -0.5, 0.0 
  Data.f  0.0,  0.5, 0.0
  Data.f  0.5, -0.5, 0.0 
 sgl::StopData()
 
 ; these are slightly different in the way params are passed
 
 vertex$ = "#version 120" + #CRLF$ 
 vertex$ + "attribute vec4 position;" + #CRLF$
 vertex$ + "void main () {" + #CRLF$
 vertex$ + " gl_Position = position;" + #CRLF$
 vertex$ + "}"
 
 fragment$ = "#version 120" + #CRLF$ 
 fragment$ + "void main () {" + #CRLF$
 fragment$ + " gl_FragColor = vec4 (1.0, 1.0, 0.0, 1.0);" + #CRLF$
 fragment$ + "}" 

 ; vertex buffer object
 glGenBuffers_(1, @vbo)
 glBindBuffer_(#GL_ARRAY_BUFFER, vbo)
 glBufferData_(#GL_ARRAY_BUFFER, 9 * SizeOf(Float), *vertexPos, #GL_STATIC_DRAW)
 
 ; vertex array object
 glGenVertexArrays_(1, @gVao)
 glBindVertexArray_(gVao)
 glBindBuffer_(#GL_ARRAY_BUFFER, vbo)
 glEnableVertexAttribArray_(0)
 glVertexAttribPointer_(0, 3, #GL_FLOAT, #GL_FALSE, 0, 0)

 Protected objects.sgl::ShaderObjects

 vs = sgl::CompileShader(vertex$, #GL_VERTEX_SHADER) 
 sgl::AddShaderObject(@objects, vs) 
 
 fs = sgl::CompileShader(fragment$, #GL_FRAGMENT_SHADER) 
 sgl::AddShaderObject(@objects, fs) 
 
 gShader = sgl::BuildShaderProgram(@objects) ; link and build the program using the specified shader objects 
 ASSERT(gShader)
 
EndProcedure


Define win

sgl::RegisterErrorCallBack(@CallBack_Error())

If sgl::Init()        

    ; we request an OpenGL 2.1 context
    
    sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_MAJOR, 2)
    sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_MINOR, 1)
    
    sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_DEBUG, 1)
            
    win = sgl::CreateWindow(640, 480, Title$)
    
    If win                
        sgl::MakeContextCurrent(win)        
        
        gl_load::Load()
        
        If sgl::IsDebugContext() = 0 Or sgl::EnableDebugOutput()  = 0 
            Debug "OpenGL debug output is not available !"
        EndIf   
             
        sgl::EnableVSYNC(#VSYNC)
                   
        SetupShaders()        
        
        While sgl::WindowShouldClose(win) = 0
            Render(win)  
            sgl::SwapBuffers(win)
            sgl::PollEvents()
        Wend    
    EndIf    
    sgl::Shutdown()
EndIf

; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 5
; FirstLine = 2
; Folding = -
; Markers = 1
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory