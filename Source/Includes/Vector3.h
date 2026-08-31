#pragma once

#ifndef _USE_MATH_DEFINES
#define _USE_MATH_DEFINES
#endif
#include <math.h>
#include <string>
#include <algorithm>

struct Vector3 {
    union {
        struct {
            float x;
            float y;
            float z;
        };
        float data[3];
    };

    inline Vector3() : x(0), y(0), z(0) {}
    inline Vector3(float d[]) : x(d[0]), y(d[1]), z(d[2]) {}
    inline Vector3(float value) : x(value), y(value), z(value) {}
    inline Vector3(float x, float y) : x(x), y(y), z(0) {}
    inline Vector3(float x, float y, float z) : x(x), y(y), z(z) {}

    static inline Vector3 zero() { return Vector3(0, 0, 0); }
    static inline Vector3 One() { return Vector3(1, 1, 1); }
    static inline Vector3 Right() { return Vector3(1, 0, 0); }
    static inline Vector3 Left() { return Vector3(-1, 0, 0); }
    static inline Vector3 Up() { return Vector3(0, 1, 0); }
    static inline Vector3 Down() { return Vector3(0, -1, 0); }
    static inline Vector3 Forward() { return Vector3(0, 0, 1); }
    static inline Vector3 Backward() { return Vector3(0, 0, -1); }

    static inline float Dot(Vector3 lhs, Vector3 rhs) {
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
    }

    static inline float Magnitude(Vector3 v) {
        return sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
    }

    static inline float Distance(Vector3 a, Vector3 b) {
        Vector3 diff = Vector3(a.x - b.x, a.y - b.y, a.z - b.z);
        return Magnitude(diff);
    }

    static inline float Angle(Vector3 a, Vector3 b) {
        float v = Dot(a, b) / (Magnitude(a) * Magnitude(b));
        v = fmaxf(v, -1.0f);
        v = fminf(v, 1.0f);
        return acosf(v);
    }

    static inline Vector3 Cross(Vector3 lhs, Vector3 rhs) {
        return Vector3(
            lhs.y * rhs.z - lhs.z * rhs.y,
            lhs.z * rhs.x - lhs.x * rhs.z,
            lhs.x * rhs.y - lhs.y * rhs.x
        );
    }

    static inline Vector3 Normalized(Vector3 v) {
        float mag = Magnitude(v);
        if (mag == 0) return Vector3::zero();
        return Vector3(v.x / mag, v.y / mag, v.z / mag);
    }

    inline Vector3 Normalize() {
        *this = Normalized(*this);
        return *this;
    }

    static inline Vector3 Lerp(Vector3 a, Vector3 b, float t) {
        t = std::max(0.0f, std::min(1.0f, t));
        return Vector3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);
    }

    inline Vector3& operator+=(const float rhs) { x += rhs; y += rhs; z += rhs; return *this; }
    inline Vector3& operator-=(const float rhs) { x -= rhs; y -= rhs; z -= rhs; return *this; }
    inline Vector3& operator*=(const float rhs) { x *= rhs; y *= rhs; z *= rhs; return *this; }
    inline Vector3& operator/=(const float rhs) { x /= rhs; y /= rhs; z /= rhs; return *this; }
    inline Vector3& operator+=(const Vector3 rhs) { x += rhs.x; y += rhs.y; z += rhs.z; return *this; }
    inline Vector3& operator-=(const Vector3 rhs) { x -= rhs.x; y -= rhs.y; z -= rhs.z; return *this; }
};

inline Vector3 operator-(Vector3 rhs) { return Vector3(-rhs.x, -rhs.y, -rhs.z); }
inline Vector3 operator+(Vector3 lhs, const float rhs) { return Vector3(lhs.x + rhs, lhs.y + rhs, lhs.z + rhs); }
inline Vector3 operator-(Vector3 lhs, const float rhs) { return Vector3(lhs.x - rhs, lhs.y - rhs, lhs.z - rhs); }
inline Vector3 operator*(Vector3 lhs, const float rhs) { return Vector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs); }
inline Vector3 operator/(Vector3 lhs, const float rhs) { return Vector3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs); }
inline Vector3 operator+(const float lhs, Vector3 rhs) { return Vector3(rhs.x + lhs, rhs.y + lhs, rhs.z + lhs); }
inline Vector3 operator-(const float lhs, Vector3 rhs) { return Vector3(lhs - rhs.x, lhs - rhs.y, lhs - rhs.z); }
inline Vector3 operator*(const float lhs, Vector3 rhs) { return Vector3(rhs.x * lhs, rhs.y * lhs, rhs.z * lhs); }
inline Vector3 operator/(const float lhs, Vector3 rhs) { return Vector3(lhs / rhs.x, lhs / rhs.y, lhs / rhs.z); }
inline Vector3 operator+(Vector3 lhs, const Vector3 rhs) { return Vector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z); }
inline Vector3 operator-(Vector3 lhs, const Vector3 rhs) { return Vector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z); }

inline bool operator==(const Vector3 lhs, const Vector3 rhs) {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z;
}

inline bool operator!=(const Vector3 lhs, const Vector3 rhs) {
    return !(lhs == rhs);
}

inline std::string to_string(Vector3 a) {
    return std::to_string(a.x) + ", " + std::to_string(a.y) + ", " + std::to_string(a.z);
}