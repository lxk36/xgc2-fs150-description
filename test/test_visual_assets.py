#!/usr/bin/env python3
"""Guard the FS150 viewer model against simplified or miscolored geometry."""

from __future__ import annotations

import struct
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


PACKAGE = Path(__file__).resolve().parents[1]


def element_by_name(root: ET.Element, tag: str, name: str) -> ET.Element:
    element = root.find(f"./{tag}[@name='{name}']")
    if element is None:
        raise AssertionError(f"missing {tag} {name}")
    return element


class Fs150VisualAssetsTest(unittest.TestCase):
    def test_visual_model_matches_gazebo_meshes_poses_and_colors(self) -> None:
        root = ET.parse(PACKAGE / "urdf" / "fs150_visual.urdf").getroot()
        expected = {
            "rotor_0": ("iris_prop_ccw.stl", "0.1 0.2 0.9 1", "0.13 -0.22 0.023"),
            "rotor_1": ("iris_prop_ccw.stl", "0.12 0.12 0.12 1", "-0.13 0.2 0.023"),
            "rotor_2": ("iris_prop_cw.stl", "0.1 0.2 0.9 1", "0.13 0.22 0.023"),
            "rotor_3": ("iris_prop_cw.stl", "0.12 0.12 0.12 1", "-0.13 -0.2 0.023"),
        }
        materials = {
            material.attrib["name"]: material.find("./color").attrib["rgba"]
            for material in root.findall("./material")
        }
        body = element_by_name(root, "link", "base_link")
        self.assertTrue(
            body.find("./visual/geometry/mesh").attrib["filename"].endswith("/iris.stl")
        )
        self.assertEqual(materials["fs150_body"], "0.84 0.71 0.10 1")

        for link_name, (mesh_name, color, origin) in expected.items():
            link = element_by_name(root, "link", link_name)
            mesh = link.find("./visual/geometry/mesh")
            material = link.find("./visual/material")
            joint = element_by_name(root, "joint", f"{link_name}_joint")
            self.assertIsNotNone(mesh)
            self.assertIsNotNone(material)
            self.assertTrue(mesh.attrib["filename"].endswith(f"/{mesh_name}"))
            self.assertEqual(materials[material.attrib["name"]], color)
            self.assertEqual(joint.find("./origin").attrib["xyz"], origin)

        self.assertFalse(root.findall(".//visual/geometry/cylinder"))
        self.assertFalse(root.findall(".//visual/geometry/box"))

    def test_viewer_stl_preserves_every_gazebo_propeller_face(self) -> None:
        for direction in ("ccw", "cw"):
            dae = ET.parse(PACKAGE / "meshes" / f"iris_prop_{direction}.dae").getroot()
            polylist = dae.find(".//{http://www.collada.org/2005/11/COLLADASchema}polylist")
            self.assertIsNotNone(polylist)

            stl = (PACKAGE / "meshes" / f"iris_prop_{direction}.stl").read_bytes()
            self.assertGreaterEqual(len(stl), 84)
            triangle_count = struct.unpack("<I", stl[80:84])[0]
            self.assertEqual(len(stl), 84 + triangle_count * 50)
            self.assertEqual(triangle_count, int(polylist.attrib["count"]))

    def test_mesh_references_resolve_inside_this_package(self) -> None:
        root = ET.parse(PACKAGE / "urdf" / "fs150_visual.urdf").getroot()
        prefix = "package://fs150_description/"
        referenced = set()
        for mesh in root.findall(".//mesh"):
            filename = mesh.attrib["filename"]
            self.assertTrue(filename.startswith(prefix), filename)
            relative = filename[len(prefix) :]
            self.assertFalse(Path(relative).is_absolute(), relative)
            self.assertNotIn("..", Path(relative).parts)
            self.assertTrue((PACKAGE / relative).is_file(), relative)
            referenced.add(relative)

        self.assertEqual(
            referenced,
            {
                "meshes/iris.stl",
                "meshes/iris_prop_ccw.stl",
                "meshes/iris_prop_cw.stl",
            },
        )

    def test_package_remains_visual_only(self) -> None:
        root = ET.parse(PACKAGE / "urdf" / "fs150_visual.urdf").getroot()
        self.assertGreater(len(root.findall(".//visual")), 0)
        for forbidden in (
            "collision",
            "inertial",
            "transmission",
            "gazebo",
            "plugin",
        ):
            self.assertEqual(root.findall(f".//{forbidden}"), [], forbidden)
        for joint in root.findall("joint"):
            self.assertEqual(joint.attrib["type"], "fixed", joint.attrib["name"])


if __name__ == "__main__":
    unittest.main()
