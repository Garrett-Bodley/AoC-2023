import z3

# thank you anatol
# https://github.com/p3achyjr/aoc/blob/main/2023/day24/part2.py

def parse_eqn(line: str):
    parts = line.split("@")
    p = [int(p) for p in parts[0].split(",")]
    v = [int(v) for v in parts[1].split(",")]

    return tuple(p), tuple(v)


def create_z3_eqns(i: int, rock_eqn, eqn):
    (px, py, pz), (pvx, pvy, pvz) = rock_eqn
    (x, y, z), (vx, vy, vz) = eqn

    t = z3.Int(f"t{i}")

    return [
        px + pvx * t == x + vx * t,
        py + pvy * t == y + vy * t,
        pz + pvz * t == z + vz * t,
    ]


if __name__ == "__main__":
    with open("input.txt") as f:
        eqns = [parse_eqn(line) for line in f.readlines()]

    px, py, pz = z3.Int("px"), z3.Int("py"), z3.Int("pz")
    vx, vy, vz = z3.Int("vx"), z3.Int("vy"), z3.Int("vz")
    rock_eqn = ((px, py, pz), (vx, vy, vz))
    z3_eqns = []
    for i, eqn in enumerate(eqns):
        z3_eqns.extend(create_z3_eqns(i, rock_eqn, eqn))

    solver = z3.Solver()
    solver.add(*z3_eqns)
    if solver.check() == z3.sat:
        m = solver.model()
        for d in m.decls():
            print(f"{d.name()} = {m[d]}")