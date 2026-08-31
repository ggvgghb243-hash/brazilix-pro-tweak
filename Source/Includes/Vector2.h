#pragma once

#ifndef _USE_MATH_DEFINES
#define _USE_MATH_DEFINES
#endif
#include <math.h>
#include <string>
#include <algorithm>

struct Vector2 {
    union {
        struct {
            float x;
            float y;
        };
        float data[2];
    };

    inline Vector2() : x(0), y(0) {}
    inline Vector2(float d[]) : x(d[0]), y(d[1]) {}
    inline Vector2(float value) : x(value), y(value) {}
    inline Vector2(float x, float y) : x(x), y(y) {}

    static inline Vector2 Zero() { return Vector2(0, 0); }
    static inline Vector2 One() { return Vector2(1, 1); }
    static inline Vector2 Right() { return Vector2(1, 0); }
    static inline Vector2 Left() { return Vector2(-1, 0); }
    static inline Vector2 Up() { return Vector2(0, 1); }
    static inline Vector2 Down() { return Vector2(0, -1); }

    static inline float Dot(Vector2 lhs, Vector2 rhs) {
        return lhs.x * rhs.x + lhs.y * rhs.y;
    }

    static inline float Magnitude(Vector2 v) {
        return sqrtf(v.x * v.x + v.y * v.y);
    }

    static inline float Distance(Vector2 a, Vector2 b) {
        return Magnitude(Vector2(a.x - b.x, a.y - b.y));
    }

    static inline Vector2 Normalized(Vector2 v) {
        float mag = Magnitude(v);
        if (mag == 0) return Vector2::Zero();
        return Vector2(v.x / mag, v.y / mag);
    }

    inline Vector2 Normalize() {
        *this = Normalized(*this);
        return *this;
    }

    inline Vector2& operator+=(const float rhs) { x += rhs; y += rhs; return *this; }
    inline Vector2& operator-=(const float rhs) { x -= rhs; y -= rhs; return *this; }
    inline Vector2& operator*=(const float rhs) { x *= rhs; y *= rhs; return *this; }
    inline Vector2& operator/=(const float rhs) { x /= rhs; y /= rhs; return *this; }
    inline Vector2& operator+=(const Vector2 rhs) { x += rhs.x; y += rhs.y; return *this; }
    inline Vector2& operator-=(const Vector2 rhs) { x -= rhs.x; y -= rhs.y; return *this; }
};

inline Vector2 operator-(Vector2 rhs) { return Vector2(-rhs.x, -rhs.y); }
inline Vector2 operator+(Vector2 lhs, const float rhs) { return Vector2(lhs.x + rhs, lhs.y + rhs); }
inline Vector2 operator-(Vector2 lhs, const float rhs) { return Vector2(lhs.x - rhs, lhs.y - rhs); }
inline Vector2 operator*(Vector2 lhs, const float rhs) { return Vector2(lhs.x * rhs, lhs.y * rhs); }
inline Vector2 operator/(Vector2 lhs, const float rhs) { return Vector2(lhs.x / rhs, lhs.y / rhs); }
inline Vector2 operator+(const float lhs, Vector2 rhs) { return Vector2(rhs.x + lhs, rhs.y + lhs); }
inline Vector2 operator-(const float lhs, Vector2 rhs) { return Vector2(lhs - rhs.x, lhs - rhs.y); }
inline Vector2 operator*(const float lhs, Vector2 rhs) { return Vector2(rhs.x * lhs, rhs.y * lhs); }
inline Vector2 operator/(const float lhs, Vector2 rhs) { return Vector2(lhs / rhs.x, lhs / rhs.y); }
inline Vector2 operator+(Vector2 lhs, const Vector2 rhs) { return Vector2(lhs.x + rhs.x, lhs.y + rhs.y); }
inline Vector2 operator-(Vector2 lhs, const Vector2 rhs) { return Vector2(lhs.x - rhs.x, lhs.y - rhs.y); }
inline Vector2 operator*(Vector2 lhs, const Vector2 rhs) { return Vector2(lhs.x * rhs.x, lhs.y * rhs.y); }

inline bool operator==(const Vector2 lhs, const Vector2 rhs) {
    return lhs.x == rhs.x && lhs.y == rhs.y;
}

inline bool operator!=(const Vector2 lhs, const Vector2 rhs) {
    return !(lhs == rhs);
}

inline std::string to_string(Vector2 a) {
    return std::to_string(a.x) + ", " + std::to_string(a.y);
}
