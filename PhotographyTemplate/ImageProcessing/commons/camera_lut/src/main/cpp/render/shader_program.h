#ifndef NATIVEIMAGEDEMO_SHADER_PROGRAM_H
#define NATIVEIMAGEDEMO_SHADER_PROGRAM_H

#include <string>
#include <GLES3/gl3.h>

namespace NativeXComponentSample {
class ShaderProgram {
public:
    ShaderProgram(const std::string &vertexShader, const std::string &fragShader);
    ~ShaderProgram() noexcept;

    // disallow copy and move
    ShaderProgram(const ShaderProgram &other) = delete;
    void operator=(const ShaderProgram &other) = delete;
    ShaderProgram(ShaderProgram &&other) = delete;
    void operator=(ShaderProgram &&other) = delete;

    bool Valid() const
    {
        return id_ > 0;
    }
    void Use() const
    {
        glUseProgram(id_);
    }

    void SetBool(const std::string &name, bool value);
    void SetInt(const std::string &name, int value);
    void SetFloat(const std::string &name, float value);
    void SetFloat4v(const std::string &name, float *values, int cnt);
    void SetMatrix4v(const std::string &name, float *matrix, int cnt, bool transpose = false);
    GLint GetAttribLocation(const std::string &name);

private:
    void CheckCompileErrors(GLuint shader, const std::string &shaderType);
    GLuint id_ = 0;
};
}  // namespace NativeXComponentSample
#endif  // NATIVEIMAGEDEMO_SHADER_PROGRAM_H
