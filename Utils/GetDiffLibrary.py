import numpy as np
from diffsims.generators.rotation_list_generators import get_beam_directions_grid
import diffpy
from diffsims.libraries.structure_library import StructureLibrary
from diffsims.generators.diffraction_generator import DiffractionGenerator
from diffsims.generators.library_generator import DiffractionLibraryGenerator
from diffsims.libraries.diffraction_library import (
    DiffractionLibrary,
    load_DiffractionLibrary,
)
import os


def GetDiffLibrary(
    diffraction_calibration: float,
    camera_length: int,
    half_radius: int,
    resolution: int = 0.3,
    cif_file: str = "/Users/anders/Library/CloudStorage/OneDrive-NTNU/Prosjektoppgave/Data/ErMnO3.cif",
    grid_cub: str = None,
    make_new: bool = False,
    minimum_intensity: float = 0.0015,
    max_excitation_error: float = 0.0125,
    center_spot: bool = False,
    precession_angle=0.3,
) -> DiffractionLibrary:

    cif_material = os.path.basename(cif_file).split(".")[0]

    filename = f"{cif_material}-{half_radius}-{camera_length}-{resolution}.difflib"

    basepath = os.path.dirname(os.path.abspath(__file__))

    filepath = os.path.join(basepath, "Libraries", filename)

    if os.path.exists(filepath) and not make_new:
        return load_DiffractionLibrary(filepath, True)

    reciprocal_radius = (
        np.sqrt(half_radius**2 + half_radius**2) * diffraction_calibration
    )

    # importing the structure: cif file
    structure_matrix = diffpy.structure.loadStructure(cif_file)

    # parameters that determine how the templates are calculated
    diff_gen = DiffractionGenerator(
        accelerating_voltage=200,
        precession_angle=precession_angle,
        scattering_params=None,
        shape_factor_model="linear",
        minimum_intensity=minimum_intensity,
    )

    lib_gen = DiffractionLibraryGenerator(diff_gen)
    if grid_cub is None:
        grid_cub = get_beam_directions_grid(
            "hexagonal", resolution, mesh="spherified_cube_edge"
        )

    # library containing structures and orientations
    library_phases = StructureLibrary(["ErMnO3"], [structure_matrix], [grid_cub])

    # final diffraction library
    diff_lib = lib_gen.get_diffraction_library(
        library_phases,
        calibration=diffraction_calibration,
        reciprocal_radius=reciprocal_radius,
        half_shape=half_radius,
        with_direct_beam=center_spot,
        max_excitation_error=max_excitation_error,
    )
    diff_lib.pickle_library(filepath)

    return diff_lib
