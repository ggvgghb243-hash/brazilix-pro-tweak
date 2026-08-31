#pragma once

#ifndef _USE_MATH_DEFINES
#define _USE_MATH_DEFINES
#endif
#include <math.h>
#include <string>
#include "Vector3.h"

struct Quaternion
{
    union
    {
        struct
        {
            float x;
            float y;
            float z;
            float w;
        };
        float data[4];
    };

    inline Quaternion() : x(0), y(0), z(0), w(1) {}
    inline Quaternion(float d[]) : x(d[0]), y(d[1]), z(d[2]), w(d[3]) {}
    inline Quaternion(Vector3 v, float scalar) : x(v.x), y(v.y), z(v.z), w(scalar) {}
    inline Quaternion(float x, float y, float z, float w) : x(x), y(y), z(z), w(w) {}

    static inline Quaternion Identity() { return Quaternion(0, 0, 0, 1); }

    static inline float Dot(Quaternion a, Quaternion b) {
        return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
    }

    static inline Quaternion Conjugate(Quaternion rotation) {
        return Quaternion(-rotation.x, -rotation.y, -rotation.z, rotation.w);
    }

    static inline Quaternion Inverse(Quaternion rotation) {
        float norm = rotation.x * rotation.x + rotation.y * rotation.y + rotation.z * rotation.z + rotation.w * rotation.w;
        return Quaternion(-rotation.x / norm, -rotation.y / norm, -rotation.z / norm, rotation.w / norm);
    }
};

inline bool operator==(const Quaternion lhs, const Quaternion rhs) {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w;
}

inline bool operator!=(const Quaternion lhs, const Quaternion rhs) {
    return !(lhs == rhs);
}

inline std::string to_string(Quaternion a) {
    return std::to_string(a.x) + ", " + std::to_string(a.y) + ", " + std::to_string(a.z) + ", " + std::to_string(a.w);
}
