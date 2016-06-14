#include "gcTerms.hpp"

// Parallel acceleration
float eval_aPar(CParticle& p, const C3Vec r, const vector<float>& r_GC, const vector<float>& bDotGradB)
{

    int status = 0;
    float This_bDotGradB = kj_interp1D(r.c1, r_GC, bDotGradB, status);
    p.status = max(p.status, status);
#if DEBUG_EVAL_APAR >= 1
    if (status > 0) {
        cout << "ERROR 1 in eval_aPar" << endl;
        exit(1);
    }
#endif
    float aPar = -p.u / p.m * This_bDotGradB;
#if DEBUG_EVAL_APRA >= 1
    if (isnan(aPar) || isinf(aPar)) {
        status = 1;
        cout << "ERROR 2 in eval_aPar" << endl;
        exit(1);
    }
#endif
    return aPar;
}

// Perpendicular velocity
float eval_vPer(CParticle& p, const C3Vec r, const vector<float>& r_b0, const vector<C3Vec>& b0_CYL)
{

    int status = 0;
    C3Vec This_b0_CYL = kj_interp1D(r.c1, r_b0, b0_CYL, status);
    p.status = max(p.status, status);
    return sqrt(2.0 * p.u * mag(This_b0_CYL) / p.m);
}

// Guiding center veclocity
C3Vec eval_vGC(CParticle& p, const C3Vec r, const float vPer, const float vPar,
    const vector<float>& r_b0, const vector<C3Vec>& b0_CYL,
    const vector<float>& r_GC, const vector<C3Vec>& curv_CYL, const vector<C3Vec>& grad_CYL)
{

    int status = 0;
    C3Vec This_b0_CYL = kj_interp1D(r.c1, r_b0, b0_CYL, status);
    p.status = max(p.status, status);
#if DEBUG_EVAL_VGC >= 1
    if (status > 0) {
        cout << "ERROR 1 in eval_vGC" << endl;
        exit(1);
    }
#endif

    status = 0;
    C3Vec This_curv_CYL = kj_interp1D(r.c1, r_GC, curv_CYL, status);
    p.status = max(p.status, status);

#if DEBUG_EVAL_VGC >= 1
    if (status > 0) {
        cout << "ERROR 2 in eval_vGC" << endl;
        exit(1);
    }
#endif

    status = 0;
    C3Vec This_grad_CYL = kj_interp1D(r.c1, r_GC, grad_CYL, status);
    p.status = max(p.status, status);
#if DEBUG_EVAL_VGC >= 1
    if (status > 0) {
        cout << "ERROR 3 in eval_vGC" << endl;
        exit(1);
    }
#endif

#if DEBUG_EVAL_VGC >= 1

    cout << "r.c1: " << r.c1 << endl;
    cout << "p.c1: " << p.c1 << endl;
    cout << "vPar: " << vPar << endl;
    cout << "vPer: " << vPer << endl;
    cout << "b0_CYL: " << This_b0_CYL.c1 << "  " << This_b0_CYL.c2 << "  " << This_b0_CYL.c3 << endl;
    cout << "curv_CYL: " << This_curv_CYL.c1 << "  " << This_curv_CYL.c2 << "  " << This_curv_CYL.c3 << endl;
    cout << "grad_CYL: " << This_grad_CYL.c1 << "  " << This_grad_CYL.c2 << "  " << This_grad_CYL.c3 << endl
         << endl;
    cout << "max(grad_CYL): " << maxC3VecAbs(grad_CYL) << endl;

#endif

    C3Vec UnitB_CYL = This_b0_CYL / mag(This_b0_CYL);

    C3Vec vGC = vPar * UnitB_CYL + pow(vPer, 2) * This_grad_CYL + pow(vPar, 2) * This_curv_CYL;
    return vGC;
}

float GetAlpComp(const float vPer, const float phs)
{

    return vPer * sin(phs);
}

float GetBetComp(const float vPer, const float phs)
{

    return vPer * cos(phs);
}